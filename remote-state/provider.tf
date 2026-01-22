/*
terraform {
  backend "s3" {
    bucket         = "mkj-cloudshell-s3bucket-31123"
    key            = "remote-state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
*/