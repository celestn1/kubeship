// kubeship/terraform/modules/eks-node-role/variables.tf
variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
}
