# this file is to set up the providers - like AWS provider , Azure provider etc

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.32.1"
    }
  }
 
  backend "s3" {
  bucket = "kalaburagi-bucket"
  key = "terraform.tfstate"
  region = "ap-south-1"
  dynamodb_table = "Remote-backend-dynamo-db"
  }
}

provider "aws" {
  # Configuration options
}


