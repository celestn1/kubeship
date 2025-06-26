// kubeship/terraform/main.tf

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# kubectl Provider
provider "kubectl" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = [
        "eks", "get-token",
        "--cluster-name", module.eks.cluster_name,
        "--region", var.aws_region
      ]
    }
  }
}

# VPC
module "vpc" {
  source             = "./modules/vpc"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = var.availability_zones
  cluster_name       = var.eks_cluster_name

  #Test Single Nat Gateway
  #  enable_nat_gateway     = true
  #  single_nat_gateway     = true
  #  one_nat_gateway_per_az = false
}

# EKS IRSA for ALB Ingress Controller
module "eks_irsa_alb" {
  source            = "./modules/eks-irsa-alb"
  project_name      = var.project_name
  environment       = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.oidc_provider, "https://", "")
}

# ALB Controller for EKS
module "alb_controller" {
  source                  = "./modules/alb-controller"
  eks_cluster_name        = var.eks_cluster_name
  aws_region              = var.aws_region
  vpc_id                  = module.vpc.vpc_id
  alb_controller_role_arn = module.eks_irsa_alb.alb_controller_role_arn
}


# EKS cluster provisioning (registry module)
module "eks_node_role" {
  source       = "./modules/eks-node-role"
  project_name = var.project_name
  environment  = var.environment
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.37.0"

  # Core cluster settings
  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnet_ids
  enable_irsa                     = true
  cluster_enabled_log_types       = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  # create_cluster_security_group   = false
  # create_node_security_group      = false  
  # enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Use the EKS Access Entry API

  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    terraform_admin = {
      principal_arn = var.terraform_caller_arn
      policy_associations = {
        cluster_admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }


  # Bring your own worker nodes
  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 2
      max_size       = 4
      instance_types = ["t3.medium"]
      iam_role_arn   = module.eks_node_role.iam_role_arn
      # optional: key_name = var.ssh_key_name
      # optional: disk_size = 20
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Cert Manager
module "cert_manager" {
  source        = "./modules/cert-manager"
  namespace     = "cert-manager"
  chart_version = "v1.14.4"

  depends_on = [
    module.eks,
    module.alb_controller
  ]
}

# Fetch EKS endpoint & auth info
data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# ECR (NGINX-gateway is merged with frontend)
module "ecr" {
  source           = "./modules/ecr"
  project_name     = var.project_name
  environment      = var.environment
  repository_names = ["auth-service", "nginx-gateway"]
}

# CloudWatch
module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.eks_cluster_name
}

# WAF
module "waf" {
  source       = "./modules/waf"
  name         = "kubeship-waf"
  description  = "WAF for kubeship ingress"
  project_name = var.project_name
  environment  = var.environment
}

# Secrets Manager
module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
  environment  = var.environment
  secrets_map  = var.secrets_map
}

# EKS IRSA for EBS CSI Driver
module "eks_irsa_ebs" {
  source            = "./modules/eks-irsa-ebs"
  project_name      = var.project_name
  environment       = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.oidc_provider, "https://", "")
}

# ArgoCD IRSA IAM Role
module "irsa_argocd" {
  source                = "./modules/irsa-argocd"
  project_name          = var.project_name
  environment           = var.environment
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  eks_oidc_provider_url = replace(module.eks.oidc_provider, "https://", "")
  argocd_namespace      = "argocd"
}

# ArgoCD GitOps Bootstrap
module "argocd_bootstrap" {
  source                   = "./modules/argocd-bootstrap"
  eks_cluster_name         = var.eks_cluster_name
  argocd_namespace         = "argocd"
  repository_url           = var.gitops_repo_url
  target_revision          = var.target_revision
  argocd_app_manifest_path = var.argocd_app_manifest_path

  install_ebs_csi             = true
  ebs_csi_controller_role_arn = module.eks_irsa_ebs.ebs_csi_controller_role_arn
  argocd_server_role_arn      = module.irsa_argocd.argocd_server_role_arn

  depends_on = [
    module.eks,
    module.eks_node_role,
    module.eks_irsa_ebs,
    module.alb_controller
  ]
}

# Data source to fetch OIDC provider URL
data "aws_iam_openid_connect_provider" "eks" {
  arn = module.eks.oidc_provider_arn
}

# IRSA for External Secrets Operator
module "irsa_external_secrets" {
  source = "./modules/irsa-external-secrets"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = data.aws_iam_openid_connect_provider.eks.url

  namespace = "external-secrets"
}

# External Secrets Operator
module "external_secrets_resources" {
  source        = "./modules/external-secrets"
  aws_region    = var.aws_region
  secrets_map   = var.secrets_map
  namespace     = "external-secrets"
  irsa_role_arn = module.irsa_external_secrets.iam_role_arn

  depends_on = [
    module.alb_controller
  ]
}
