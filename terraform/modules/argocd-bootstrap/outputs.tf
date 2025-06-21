// kubeship/terraform/modules/argocd-bootstrap/outputs.tf

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_lb_hostname" {
  description = "LoadBalancer hostname of ArgoCD server"
  value       = helm_release.argocd.status[0].load_balancer_ingress[0].hostname
  // Note: This may be empty if LB is not ready immediately
  // Alternatively use a kubernetes_service data source if needed
}