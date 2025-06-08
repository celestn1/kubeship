// kubeship/terraform/bootstrap/outputs.tf

output "s3_backend_bucket" {
  value       = aws_s3_bucket.tf_state.id
  description = "Name of the S3 bucket used for Terraform state"
}

output "dynamodb_lock_table" {
  value       = aws_dynamodb_table.tf_lock.name
  description = "Name of the DynamoDB table used for Terraform state locking"
}
