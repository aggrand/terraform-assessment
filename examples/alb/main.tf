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

module "alb" {
  source   = "../../modules/networking/alb"
  alb_name = "example-test-alb"
}
