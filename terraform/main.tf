// kubeship/terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# Backend configuration stored in backend.tf separately

# VPC
module "vpc" {
  source        = "./modules/vpc"
  project_name  = var.project_name
  environment   = var.environment
  vpc_cidr_block    = var.vpc_cidr_block
  availability_zones  = var.availability_zones
}

# EKS
module "eks" {
  source           = "./modules/eks"
  project_name     = var.project_name
  environment      = var.environment
  cluster_name     = var.eks_cluster_name
  vpc_id           = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  cluster_version  = var.eks_cluster_version
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
  source        = "./modules/cloudwatch"
  project_name  = var.project_name
  environment   = var.environment
  cluster_name  = var.eks_cluster_name
}

# WAF — with ALB integration
module "waf" {
  source        = "./modules/waf"
  name          = "kubeship-waf"
  description   = "WAF for kubeship ingress"
  project_name  = var.project_name
  environment   = var.environment
  alb_arn       = var.alb_arn # passed as external value or derived dynamically
}

# Secrets Manager
module "secrets" {
  source        = "./modules/secrets"
  project_name  = var.project_name
  environment   = var.environment
  secrets_map   = var.secrets_map
}

# ArgoCD GitOps Bootstrap
module "argocd_bootstrap" {
  source                      = "./modules/argocd-bootstrap"
  eks_cluster_name            = var.eks_cluster_name
  argocd_namespace            = "argocd"
  repository_url              = var.gitops_repo_url
  target_revision             = "main"
  argocd_app_manifest_path    = "manifests"

}
