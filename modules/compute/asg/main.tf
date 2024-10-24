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
  server_port  = 8080
  tcp_protocol = "tcp"
  all_ips      = "0.0.0.0/0"
}

resource "aws_launch_template" "module_template" {
  name                   = "${var.cluster_name}-template"
  image_id               = var.instance_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

# TODO: Only allow access from lb
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.instance.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.tcp_protocol
  from_port   = local.server_port
  to_port     = local.server_port
}

resource "aws_autoscaling_group" "module_asg" {
  launch_template {
    id = aws_launch_template.module_template.id
  }
  vpc_zone_identifier = var.subnet_ids

  # TODO: Add target group arns
  #target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-asg"
    propagate_at_launch = true
  }
}
