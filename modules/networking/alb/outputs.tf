output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.module_lb.dns_name
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "lb_sg_id" {
  description = "ID of the security group of the load balancer"
  value       = aws_security_group.alb.id
}
