terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.72.1"
      configuration_aliases = [aws.recovery]
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [module.primary_bucket.bucket_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${module.primary_bucket.bucket_arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${module.recovery_bucket.bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "replication" {
  name   = "tf-iam-role-policy-replication-${var.bucket_name}"
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role" "replication" {
  name               = "tf-iam-role-replication-${var.bucket_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

# Note: If we ever make versioning optional in the s3 module, we must still require it here.
module "primary_bucket" {
  source      = "../s3"
  bucket_name = var.bucket_name
}

module "recovery_bucket" {
  source = "../s3"

  providers = {
    aws = aws.recovery
  }
  bucket_name = "${var.bucket_name}-recovery"
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  depends_on = [module.primary_bucket]

  role   = aws_iam_role.replication.arn
  bucket = module.primary_bucket.bucket_id

  rule {
    status = "Enabled"

    destination {
      bucket        = module.recovery_bucket.bucket_arn
      storage_class = "STANDARD"
    }
  }
}
