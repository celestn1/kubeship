// kubeship/terraform/modules/secrets/outputs.tf

output "secret_arns" {
  description = "ARNs of the secrets"
  value = {
    for k, v in aws_secretsmanager_secret.this : k => v.arn
  }
}

output "secret_names" {
  description = "Names of the secrets"
  value       = keys(aws_secretsmanager_secret.this)
}
