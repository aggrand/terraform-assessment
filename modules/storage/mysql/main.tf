terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

resource "aws_db_instance" "module_db" {
  identifier_prefix     = "${var.cluster_name}-db"
  engine                = "mysql"
  allocated_storage     = 10
  instance_class        = "db.t3.micro"
  multi_az              = var.multi_az
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true
  db_name               = var.db_name

  username = var.db_username
  password = var.db_password

  # This could be controversial; arguably it's bad for stability if you're accidentally "relying" on a bug, but updates to fix security holes are good things.
  auto_minor_version_upgrade = true

  # Not sure about the performance impact of this, but enabling it by default and disabling later if we need better performance might be a good idea.
  storage_encrypted = true

  enabled_cloudwatch_logs_exports = ["general", "error", "slowquery"]

  #checkov:skip=CKV_AWS_293:Setting up optional deletion protection (via argument?) is future work
  #checkov:skip=CKV_AWS_161:We should use IAM here, but I think that's a lot to configure. It's a TODO item for now.
  #checkov:skip=CKV_AWS_354:KMS is a future TODO item
  #checkov:skip=CKV_AWS_118:More fine-grained monitoring may depend on the use case. We'll stick with the default for now and change as needed.
}
