terraform {
  required_version = "1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.72.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "asg" {
  source = "../../modules/compute/asg"

  cluster_name = "example-cluster"

  # Ubuntu AMI: https://cloud-images.ubuntu.com/locator/ec2/
  instance_ami  = "ami-0b0ea68c435eb488d"
  instance_type = "t2.micro"

  subnet_ids = data.aws_subnets.default.ids

  min_size = 1
  max_size = 1
}
