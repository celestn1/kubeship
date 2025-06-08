// kubeship/terraform/modules/ecr/outputs.tf

output "ecr_repository_urls" {
  value = {
    for name, repo in aws_ecr_repository.this :
    name => repo.repository_url
  }
  description = "Map of ECR repository names to their URLs"
}
