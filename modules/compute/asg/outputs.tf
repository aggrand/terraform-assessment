output "instance_port" {
  description = "The port on which the server is listening"
  value       = local.server_port
}

output "ec2_sg_id" {
  description = "The ID of the security group of the EC2 instances"
  value       = aws_security_group.instance.id
}
