terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket = "roboshop-cicd-remote-state"
    key    = "roboshop-cicd-tools-key"
    region = "us-east-1"
    dynamodb_table = "roboshop-cicd-locking"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}