// kubeship/terraform/modules/ecr/variables.tf

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}
