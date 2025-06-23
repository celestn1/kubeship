// kubeship/terraform/modules/secrets/variables.tf

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all secrets"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "The AWS region where secrets will be stored"
  type        = string
  default     = "eu-west-2"
}

variable "secrets_map" {
  description = "Map of secret names to a map of key→value pairs"
  type        = map(map(string))
}
