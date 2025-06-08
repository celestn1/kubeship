// kubeship/terraform/modules/secrets/outputs.tf

output "secret_arn" {
  description = "The ARN of the created secret"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "The name of the created secret"
  value       = aws_secretsmanager_secret.this.name
}