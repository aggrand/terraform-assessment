terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "../../modules/storage/s3"

  bucket_name = var.bucket_name

  enable_logging = false
  logging_bucket = ""
}
