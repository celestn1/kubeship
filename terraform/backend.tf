terraform {
  backend "s3" {
    bucket         = "kubeship-tf-state"
    key            = "infra/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "kubeship-tf-locks"
    encrypt        = true
  }
}
