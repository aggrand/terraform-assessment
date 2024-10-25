terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

# TODO: Remove and create VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "db" {
  source = "../../storage/mysql"

  cluster_name = var.app_name
  db_name      = var.app_name

  # To enable later; it's slow for testing
  multi_az = false

  db_username = var.db_username
  db_password = var.db_password

  ec2_sg_id = module.asg.ec2_sg_id
}

module "asg" {
  source = "../../compute/asg"

  cluster_name = var.app_name

  instance_ami  = var.instance_ami
  instance_type = var.instance_type

  subnet_ids = data.aws_subnets.default.ids

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    server_port = module.asg.instance_port
    db_address  = module.db.address
    db_port     = module.db.port
  }))

  target_group_arn = aws_lb_target_group.asg.arn
  lb_sg_id         = module.alb.lb_sg_id

  min_size = var.min_size
  max_size = var.max_size
}

module "alb" {
  source = "../../networking/alb"

  alb_name   = "${var.app_name}-alb"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.app_name}-asg"
  port     = module.asg.instance_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.http_listener_arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
