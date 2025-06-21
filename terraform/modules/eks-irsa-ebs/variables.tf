# kubeship/terraform/modules/eks-irsa-ebs/variables.tf

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN from EKS module"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL (without https://)"
}
