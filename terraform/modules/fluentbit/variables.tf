// kubeship/terraform/modules/fluentbit/variables.tf

variable "log_group_name" {
  description = "CloudWatch log group name for container logs"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch logs"
  type        = string
}

variable "iam_role_arn" {
  description = "IAM Role ARN for Fluent Bit pod (IRSA)"
  type        = string
}
