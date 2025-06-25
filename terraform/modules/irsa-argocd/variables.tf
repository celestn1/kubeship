# kubeship/terraform/modules/irsa-argocd/variables.tf

variable "project_name" {
  type        = string
  description = "Prefix for naming the IRSA role"
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g. dev, prod)"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN of the EKS cluster’s OIDC provider"
}

variable "eks_oidc_provider_url" {
  type        = string
  description = "URL of the EKS cluster’s OIDC provider (without https://)"
}

variable "argocd_namespace" {
  type        = string
  description = "Namespace where ArgoCD is installed (usually \"argocd\")"
}
