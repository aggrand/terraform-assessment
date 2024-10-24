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

module "db" {
  source = "../../modules/storage/mysql"

  cluster_name = "example-cluster"
  db_name      = "exampleDatabase"
  multi_az     = var.multi_az

  db_username = var.db_username
  db_password = var.db_password
}
