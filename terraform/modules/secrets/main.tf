// kubeship/terraform/modules/secrets/main.tf

resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets_map

  name = each.key

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_secretsmanager_secret_version" "version" {
  for_each = var.secrets_map

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = each.value
}
