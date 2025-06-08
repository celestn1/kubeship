// kubeship/terraform/modules/ecr/outputs.tf

output "ecr_repository_urls" {
  description = "Map of repository names to ECR URLs"
  value = {
    for repo in aws_ecr_repository.this :
    repo.name => repo.repository_url
  }
}
