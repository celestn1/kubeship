// kubeship/terraform/main.tf

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

# Image digest variables
variable "auth_image_digest" {
  description = "sha256 digest for the auth-service image"
  type        = string
  default     = ""
}

variable "frontend_image_digest" {
  description = "sha256 digest for the frontend image"
  type        = string
  default     = ""
}

variable "nginx_image_digest" {
  description = "sha256 digest for the nginx-gateway image"
  type        = string
  default     = ""
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

# EKS cluster provisioning (wrapper module)
module "eks" {
  source             = "./modules/eks"
  project_name       = var.project_name
  environment        = var.environment
  cluster_name       = var.eks_cluster_name
  cluster_version    = var.eks_cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = false
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
}

# AWS-Auth bootstrap submodule - Updated
module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.36.0"

  eks_cluster_id = module.eks.cluster_name

  aws_auth_roles = [
    {
      rolearn  = var.terraform_caller_arn
      username = "terraform-admin"
      groups   = ["system:masters"]
    }
  ]
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

# WAF — dynamically receive ALB ARN
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
