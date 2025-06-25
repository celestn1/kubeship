// kubeship/terraform/modules/waf/variables.tf

variable "name" {
  description = "Name of the WAF WebACL"
  type        = string
}

variable "description" {
  description = "Description for the WAF WebACL"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project tag"
  type        = string
}

variable "environment" {
  description = "Environment (e.g. dev, staging, prod)"
  type        = string
}

