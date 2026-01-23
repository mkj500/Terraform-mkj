terraform {
  backend "s3" {
    bucket         = "mkj-cloudshell-s3bucket-31123"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-remote-state"
  }
}

provider "aws" {
  region = "us-east-1"
}
