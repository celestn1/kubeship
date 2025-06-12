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
  type        = map(string)
  description = "Common tags to apply to all secrets"
  default     = {}
}

variable "secrets_map" {
  description = "Map of secret names to values"
  type        = map(string)
}

variable "aws_region" {
  description = "The AWS region where secrets will be stored"
  type        = string
  default     = "eu-west-2"
}