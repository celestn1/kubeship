# kubeship/terraform/modules/irsa-external-secrets/variables.tf

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace where the external-secrets service account lives"
  type        = string
  default     = "external-secrets"
}
