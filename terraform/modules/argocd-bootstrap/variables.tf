// kubeship/terraform/modules/argocd-bootstrap/variables.tf

variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "5.51.6"
}

variable "argocd_namespace" {
  description = "Namespace for installing ArgoCD"
  type        = string
  default     = "argocd"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "repository_url" {
  description = "Git repository URL for manifests"
  type        = string
}

variable "target_revision" {
  description = "Git revision to deploy (e.g., main, HEAD)"
  type        = string
}

variable "argocd_app_manifest_path" {
  description = "Path in the Git repository where ArgoCD application manifests are located"
  type        = string
}

variable "install_ebs_csi" {
  type    = bool
  default = true
  description = "Whether to install AWS EBS CSI driver and gp3 StorageClass"
}

variable "ebs_csi_controller_role_arn" {
  type        = string
  description = "Role ARN for the EBS CSI controller"
}
