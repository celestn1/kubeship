// kubeship/terraform/variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}


variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "alb_arn" {
  description = "The ARN of the ALB to associate with WAF"
  type        = string
}

variable "gitops_repo_url" {
  description = "URL of the GitOps repo for ArgoCD"
  type        = string
}

variable "secrets_map" {
  description = "Map of secrets to store in AWS Secrets Manager"
  type        = map(string)
  default     = {}
}
