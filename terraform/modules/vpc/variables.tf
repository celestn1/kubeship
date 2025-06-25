// kubeship/terraform/modules/vpc/variables.tf

variable "project_name" {
  description = "Name of the project for tagging"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}


variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, prod), staging"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (used for subnet tagging)"
  type        = string
}

# ===================================== Single NAT Gateway Configuration =====================================
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for outbound internet access"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Create a single shared NAT Gateway across all AZs"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per AZ"
  type        = bool
  default     = true
}
