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

resource "aws_lb" "module_lb" {
  name                       = var.alb_name
  load_balancer_type         = "application"
  subnets                    = var.subnet_ids
  security_groups            = [aws_security_group.alb.id]
  drop_invalid_header_fields = true

  #checkov:skip=CKV_AWS_150:Setting up optional deletion protection (via argument?) is future work
  #checkov:skip=CKV_AWS_91:Setting up logging is future work
  #checkov:skip=CKV2_AWS_20:Setting up HTTPS certs is future work
  #checkov:skip=CKV2_AWS_31::Setting up kinesis and logging is future work
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.module_lb.arn
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

  #checkov:skip=CKV_AWS_2:Setting up HTTPS certs is future work
  #checkov:skip=CKV_AWS_103:Setting up HTTPS certs is future work
}

resource "aws_security_group" "alb" {
  name        = var.alb_name
  description = "Allow http from anywhere and allow all egress"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  description       = "Allow http from anywhere"
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.tcp_protocol
  from_port   = local.http_port
  to_port     = local.http_port

  #checkov:skip=CKV_AWS_260:This ALB is public-facing. Future work could hide it behind a CDN or similar.
}

# TODO: Make conditional on variable
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  description       = "Allow all egress"
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = local.all_ips
  ip_protocol = local.any_protocol
  from_port   = local.any_port
  to_port     = local.any_port
}

# Mostly taken from here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl
# This needs more examination in detail. I only kinda understand it. This sort of thing benefits from heavy code review.
# TODO Should this be a separate module?
resource "aws_wafv2_web_acl" "common_rules" {
  name        = "example-web-acl"
  scope       = "REGIONAL" # Cambiar a "CLOUDFRONT" si es necesario
  description = "WAFv2 Web ACL with AWSManagedRulesCommonRuleSet"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "general-metric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-Common-RuleSet"
    priority = 1
    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common-rule-set"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "bad-input-rule-set"
      sampled_requests_enabled   = true
    }
  }
  #checkov:skip=CKV2_AWS_31:Setting up kinesis logging is future work
}

resource "aws_wafv2_web_acl_association" "common_rules" {
  resource_arn = aws_lb.module_lb.arn
  web_acl_arn  = aws_wafv2_web_acl.common_rules.arn
}
