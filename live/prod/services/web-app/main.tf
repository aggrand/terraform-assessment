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
    key            = "prod/services/web-app"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "web-app" {
  source = "../../../../modules/services/web-app"

  app_name = "example"

  # Ubuntu in us-east-1
  instance_ami  = "ami-0cad6ee50670e3d0e"
  instance_type = "t2.micro"

  min_size = 2
  max_size = 10

  db_username = var.db_username
  db_password = var.db_password
}
