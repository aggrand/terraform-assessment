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
  encryption = "AES256"
}

resource "aws_s3_bucket" "module_bucket" {
  bucket = var.bucket_name

  # TODO: Find a way to parameterize?
  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.module_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.module_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.encryption
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.module_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
