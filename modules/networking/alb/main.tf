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
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = "0.0.0.0/0"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "main_lb" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = local.http_port
  protocol          = "HTTP"

  # Return 404 page unless otherwise stated
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = var.alb_name
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.tcp_protocol
  from_port   = local.http_port
  to_port     = local.http_port
}

# TODO: Make conditional on variable
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.any_protocol
  from_port   = local.any_port
  to_port     = local.any_port
}
