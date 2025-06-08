// kubeship/terraform/modules/secrets/main.tf

resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets_map

  name = "${var.project_name}/${each.key}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "version" {
  for_each = var.secrets_map

  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}
