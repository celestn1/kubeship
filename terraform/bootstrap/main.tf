# kubeship/terraform/bootstrap/main.tf
# This Terraform configuration sets up the backend for storing the Terraform state
# in an S3 bucket and uses a DynamoDB table for state locking.

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "kubeship-tf-state"
  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "kubeship-tf-state"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state_block" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = "kubeship-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "kubeship-tf-locks"
    Environment = "dev"
  }
}
