// kubeship/terraform/modules/ecr/outputs.tf

output "ecr_repository_urls" {
  description = "URLs of the created ECR repositories"
  value = {
    for repo in aws_ecr_repository.this :
    repo.key => repo.value.repository_url
  }
}

