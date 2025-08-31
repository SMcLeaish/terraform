provider "aws" {
  region = "us-east-1"
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name = "terraform-state-lock-dynamo"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    encrypt         = true
    bucket          = "sm-tf-state-bucket-0"
    dynamodb_table  = "terraform-state-lock-dynamo"
    key             = "terraform_setup/terraform.tfstate"
    region          = "us-east-1"
  }
}
resource "aws_s3_bucket" "tf_state_bucket" {
    bucket = "sm-tf-state-bucket-0"
}
resource "aws_s3_bucket_versioning" "tf_state_bucket_versioning" {
  bucket = aws_s3_bucket.tf_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

