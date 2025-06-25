# kubeship/terraform/modules/irsa-argocd/outputs.tf

output "argocd_server_role_arn" {
  description = "IAM Role ARN for the ArgoCD server IRSA"
  value       = aws_iam_role.argocd_server.arn
}