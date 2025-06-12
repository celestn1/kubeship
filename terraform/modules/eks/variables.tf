// kubeship/terraform/modules/eks/variables.tf
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.26"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for EKS"
  type        = list(string)
}

variable "cluster_enabled_log_types" {
  description = "List of log types to enable on the cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_irsa" {
  description = "Whether to enable IRSA"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Public access for the EKS control plane"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Private access for the EKS control plane"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to access the public EKS endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ── Access Entry API inputs ──
variable "authentication_mode" {
  description = "Mode for auth: SERVICE_ACCOUNT, API_AND_CONFIG_MAP, or CONFIG_MAP"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "terraform_caller_arn" {
  description = "IAM role ARN to map into EKS"
  type        = string
}

variable "cluster_admin_policy_arn" {
  description = "Policy ARN to use for cluster-admin mapping"
  type        = string
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}
# ─────────────────────────────

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
