terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket         = "aggrand-assessment-terraform-state"
    region         = "us-east-1"
    dynamodb_table = "aggrand-assessment-terraform-state"
    key            = "global/s3/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-west-1"
  alias  = "recovery"
}

module "s3-replicated" {
  source = "../../../modules/storage/s3-replicated"

  providers = {
    aws.recovery = aws.recovery
  }

  bucket_name = "aggrand-assessment-terraform-state"
}

module "dynamo" {
  source = "../../../modules/storage/dynamo"

  table_name = "aggrand-assessment-terraform-state"
}
