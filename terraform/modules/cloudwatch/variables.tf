// kubeship/terraform/modules/cloudwatch/variables.tf

variable "cluster_name" {
  description = "EKS cluster name used in log group naming"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
