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
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to deploy resources into"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.26"
}

variable "gitops_repo_url" {
  description = "Git repository URL for ArgoCD manifests"
  type        = string
}

variable "target_revision" {
  description = "Git revision (branch/tag) for ArgoCD to track"
  type        = string
}

variable "argocd_app_manifest_path" {
  description = "Path in the repo where ArgoCD Application YAMLs live"
  type        = string
  default     = ""
}

variable "terraform_caller_arn" {
  description = "IAM role ARN used by Terraform (needs cluster-admin on EKS)"
  type        = string
}

variable "secrets_map" {
  description = "Map of secret names to values for AWS Secrets Manager"
  type        = map(string)
  default     = {}
}

variable "auth_image_digest" {
  description = "SHA256 digest for the auth-service Docker image"
  type        = string
  default     = ""
}

variable "frontend_image_digest" {
  description = "SHA256 digest for the frontend Docker image"
  type        = string
  default     = ""
}

variable "nginx_image_digest" {
  description = "SHA256 digest for the nginx-gateway Docker image"
  type        = string
  default     = ""
}
