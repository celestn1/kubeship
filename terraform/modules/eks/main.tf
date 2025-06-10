// kubeship/terraform/modules/eks/main.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 20.37.0"

  # Core cluster settings
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.private_subnet_ids
  enable_irsa                     = true

  cluster_enabled_log_types       = var.cluster_enabled_log_types
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # ── NEW: Access Entry API instead of aws-auth blocks ──────
  authentication_mode = var.authentication_mode

  access_entries = {
    terraform_admin = {
      principal_arn = var.terraform_caller_arn
      policy_associations = {
        cluster_admin = {
          policy_arn   = var.cluster_admin_policy_arn
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  # tagging
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

    eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 1
      max_size       = 3
      min_size       = 1
    }
  }
}
