// kubeship/terraform/modules/irsa-fluentbit/outputs.tf

output "role_arn" {
  value = aws_iam_role.this.arn
}
