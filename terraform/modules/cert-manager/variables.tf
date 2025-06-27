# kubeship/terraform/modules/cert-manager/variables.tf

variable "namespace" {
  description = "Namespace where cert-manager will be installed"
  type        = string
  default     = "cert-manager"
}

variable "chart_version" {
  description = "Version of the cert-manager Helm chart"
  type        = string
  default     = "v1.18.1"
}
