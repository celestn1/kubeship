// kubeship/terraform/modules/ecr/main.tf

resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repository_names)

  name = each.value

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = each.value
    Project     = var.project_name
    Environment = var.environment
  }
}
