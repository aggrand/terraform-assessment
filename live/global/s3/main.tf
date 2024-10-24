terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }

  backend "s3" {
    bucket         = "terraform-assessment-aggrand"
    region         = "us-east-1"
    dynamodb_table = "terraform-assessment-locks"
    key            = "global/s3/terraform.tfstate"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "primary_region"
}

provider "aws" {
  region = "us-west-1"
  alias  = "recovery_region"
}

resource "aws_s3_bucket" "terraform_state" {
  provider = aws.primary_region
  bucket   = "terraform-assessment-aggrand"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  provider = aws.primary_region
  bucket   = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  provider = aws.primary_region
  bucket   = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  provider = aws.primary_region
  bucket   = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  provider     = aws.primary_region
  name         = "terraform-assessment-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
  #checkov:skip=CKV_AWS_28:Terraform locks are transient and a new valid state can be created with force-unlock
  #checkov:skip=CKV_AWS_119:Terraform locks are not secret (or at least in this project)
}
