// kubeship/terraform/bootstrap/main.tf

# run once to set up the S3 bucket and DynamoDB table for Terraform state Manageme
provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Terraform state
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.state_bucket
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
  }
}

# DynamoDB Table for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = var.environment
  }
}

