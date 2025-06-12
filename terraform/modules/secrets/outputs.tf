// kubeship/terraform/modules/secrets/outputs.tf

output "secret_arns" {
  description = "Map of secret keys to their ARNs"
  value = {
    for key, secret in aws_secretsmanager_secret.secrets :
    key => secret.arn
  }
}

output "secret_names" {
  description = "Names of the secrets"
  value       = keys(aws_secretsmanager_secret.this)
}
