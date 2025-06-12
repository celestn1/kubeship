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
  }
}

provider "aws" {
  region = var.aws_region
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
    token                  = data.aws_eks_cluster_auth.this.token
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
}

# ALB
module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

# EKS cluster provisioning (registry module)
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
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # Use the EKS Access Entry API (no more aws-auth blocks)
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
      desired_size   = 1
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.medium"]
      # optional: key_name = var.ssh_key_name
      # optional: disk_size = 20
    }
  }  

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# ECR
module "ecr" {
  source           = "./modules/ecr"
  project_name     = var.project_name
  environment      = var.environment
  repository_names = ["auth-service", "frontend", "nginx-gateway"]
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
  alb_arn      = module.alb.alb_arn
}

# Secrets Manager
module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
  environment  = var.environment
  secrets_map  = var.secrets_map
}

# ArgoCD GitOps Bootstrap
module "argocd_bootstrap" {
  source                   = "./modules/argocd-bootstrap"
  eks_cluster_name         = var.eks_cluster_name
  argocd_namespace         = "argocd"
  repository_url           = var.gitops_repo_url
  target_revision          = var.target_revision
  argocd_app_manifest_path = var.argocd_app_manifest_path
}

# External Secrets Operator
module "external_secrets" {
  source     = "./modules/external-secrets"
  aws_region = var.aws_region
  namespace  = "default"
  secrets_map = {}
}

module "external_secrets_resources" {
  source      = "./modules/external-secrets"
  aws_region  = var.aws_region  
  secrets_map = var.secrets_map
  namespace   = "default"
}
