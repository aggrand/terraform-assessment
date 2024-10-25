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
  tcp_protocol = "tcp"
  any_port     = 0
  any_protocol = "-1"
  all_ips      = ["0.0.0.0/0"]
  server_port  = 8080
}

resource "aws_launch_template" "module_template" {
  name_prefix            = "${var.cluster_name}-"
  image_id               = var.instance_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data              = var.user_data
  update_default_version = true

  key_name = "main-key-pair"

  # Required when using a launch template with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }

  #checkov:skip=CKV_AWS_79:Disabling metadata service would be future work
}

resource "aws_autoscaling_group" "module_asg" {
  name_prefix = "${var.cluster_name}-"

  launch_template {
    id = aws_launch_template.module_template.id
  }
  vpc_zone_identifier = var.subnet_ids

  target_group_arns = [var.target_group_arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name_prefix = "${var.cluster_name}-instance-"
  description = "Allow http inbound"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  description       = "Allow http inbound from the load balancer and outbound to db"
  security_group_id = aws_security_group.instance.id

  from_port                = local.server_port
  to_port                  = local.server_port
  protocol                 = local.tcp_protocol
  source_security_group_id = var.lb_sg_id
}

# This is just for testing
resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  description       = "Allow ssh inbound"
  security_group_id = aws_security_group.instance.id

  from_port   = 22
  to_port     = 22
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# TODO: Restrict to just the db
resource "aws_security_group_rule" "allow_outbound_to_db" {
  type              = "egress"
  security_group_id = aws_security_group.instance.id

  from_port                = local.any_port
  to_port                  = local.any_port
  protocol                 = local.any_protocol
  source_security_group_id = var.db_sg_id
}
