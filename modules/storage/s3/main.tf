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

  #checkov:skip=CKV_AWS_144:Cross-region replication is handled by the s3-replicated module
  #checkov:skip=CKV_AWS_145:KMS is a future TODO item
}

# This basically mimics the default.
resource "aws_s3_bucket_lifecycle_configuration" "module_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "rule-1"
    status = "Enabled"
  }
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

resource "aws_sns_topic" "bucket_notifications" {
  name = "${var.bucket_name}-bucket-notifications"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn = aws_sns_topic.bucket_notifications.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
    ]
  }
}

resource "aws_s3_bucket_logging" "module_bucket_logging" {
  count  = var.enable_logging ? 1 : 0
  bucket = var.logging_bucket

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/${var.bucket_name}/"
}
