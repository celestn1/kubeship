// kubeship/terraform/modules/secrets/variables.tf

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "secrets_map" {
  description = "Map of secret names to values"
  type        = map(string)
}
