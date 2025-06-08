// kubeship/terraform/modules/irsa-fluentbit/variables.tf

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}
