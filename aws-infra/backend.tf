provider "aws" {
  region = "us-east-1"
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

