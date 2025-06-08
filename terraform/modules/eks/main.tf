// kubeship/terraform/modules/eks/main.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.private_subnet_ids
  vpc_id          = var.vpc_id

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  enable_irsa               = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      max_size       = 3
      min_size       = 1
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
