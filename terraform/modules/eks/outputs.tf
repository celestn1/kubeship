// kubeship/terraform/modules/eks/outputs.tf

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS API endpoint"
}

output "kubeconfig" {
  value       = module.eks.kubeconfig
  description = "Kubeconfig content for the EKS cluster"
}
