terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

// This region, as the default without an alias, will the the primary region the bucket is in.
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-west-1"
  alias  = "recovery"
}

module "s3-replicated" {
  source = "../../modules/storage/s3-replicated"

  providers = {
    aws.recovery = aws.recovery
  }

  bucket_name = var.bucket_name
}
