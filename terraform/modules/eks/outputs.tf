// kubeship/terraform/modules/eks/outputs.tf

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate_data" {
  description = "CA cert data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
}