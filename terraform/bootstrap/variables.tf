// kubeship/terraform/bootstrap/variables.tf

variable "aws_region" {
  description = "AWS region to deploy the backend infra"
  type        = string
  default     = "eu-west-2"
}

variable "state_bucket" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
  default     = "kubeship-tf-state"
}

variable "lock_table" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "kubeship-tf-lock"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
}
