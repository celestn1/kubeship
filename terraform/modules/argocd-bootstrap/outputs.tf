// kubeship/terraform/modules/argocd-bootstrap/outputs.tf

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
