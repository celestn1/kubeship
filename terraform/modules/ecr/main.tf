// kubeship/terraform/modules/ecr/main.tf

variable "repository_names" {
  type = list(string)
}

variable "project_name" {
  type = string
}

locals {
  repo_set = toset(var.repository_names)
}

# Lookup any existing ECR repositories
data "aws_ecr_repository" "maybe_exists" {
  for_each = local.repo_set
  # The 'name' argument is required to specify the repository
  name     = "${var.project_name}-${each.key}"
}

# Create only those repositories which do not already exist
resource "aws_ecr_repository" "this" {
  for_each = {
    for repo in local.repo_set :
    repo => repo
    if try(data.aws_ecr_repository.maybe_exists[repo].arn, "") == ""
  }

  name = "${var.project_name}-${each.key}"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    name = "${var.project_name}-${each.key}"
  }
}
