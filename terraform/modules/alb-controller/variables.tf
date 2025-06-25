// kubeship/terraform/modules/alb-controller/variables.tf

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IAM Role ARN for the AWS Load Balancer Controller ServiceAccount"
  type        = string
}
