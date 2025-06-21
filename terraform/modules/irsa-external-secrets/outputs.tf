# kubeship/terraform/modules/irsa-external-secrets/outputs.tf

output "role_arn" {
  value = aws_iam_role.this.arn
}
