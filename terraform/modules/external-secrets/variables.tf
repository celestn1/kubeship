# modules/external-secrets/variables.tf
variable "aws_region" {
  description = "AWS region"
  type 				= string
  default     = "eu-west-2"    
}

variable "secrets_map" {
  description = "Map of runtime secrets injected dynamically from CI"	
  type = map(string)
  default     = {}	
}

variable "namespace" {
  description = "Namespace to install External Secrets"
  type        = string
  default     = "external-secrets"
}