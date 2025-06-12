# modules/external-secrets/variables.tf
variable "aws_region" {
  type 				= string
  default     = "eu-west-2"    
}

variable "secrets_map" {
  description = "Map of runtime secrets injected dynamically from CI"	
  type = map(string)
  default     = {}	
}

variable "namespace" {
  type = string
}