// kubeship/terraform/modules/external-secrets/variables.tf

variable "aws_region" {
  description = "AWS region for the External-Secrets Operator"
  type        = string
}

variable "secrets_map" {
  description = "Map of AWS Secret names to a map of key→value pairs"
  type        = map(map(string))
  default     = {}
}

variable "namespace" {
  description = "Namespace to install External-Secrets into"
  type        = string
  default     = "external-secrets"
}

variable "irsa_role_arn" {
  description = "IAM Role ARN for External-Secrets IRSA"
  type        = string
}
