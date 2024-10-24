terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

locals {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  type         = "S"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.table_name
  billing_mode = local.billing_mode
  hash_key     = local.hash_key

  attribute {
    name = local.hash_key
    type = local.type
  }
  #checkov:skip=CKV_AWS_28:Terraform locks are transient and a new valid state can be created with force-unlock
  #checkov:skip=CKV_AWS_119:Terraform locks are not secret (or at least in this project)
}
