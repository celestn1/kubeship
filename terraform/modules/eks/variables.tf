// kubeship/terraform/modules/eks/variables.tf

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

# ── New endpoint-access variables ──
variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API server public endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API server private endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDRs allowed to access the public EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "map_roles" {
  description = "List of IAM role → Kubernetes user/group mappings for aws-auth"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}