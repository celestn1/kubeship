// kubeship/terraform/modules/secrets/main.tf

resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets_map

  name        = each.key
  description = "Managed secret ${each.key} for ${var.environment}"

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags_all]
  }

  tags = merge({
    Environment = var.environment
    Project     = var.project_name
  }, var.tags)
}

resource "aws_secretsmanager_secret_version" "secrets_version" {
  for_each    = aws_secretsmanager_secret.secrets
  secret_id   = each.value.id

  # JSON-encode the inner map, or default to empty object
  secret_string = jsonencode(
    try(var.secrets_map[each.key], {})
  )

  version_stages = ["AWSCURRENT"]
}
