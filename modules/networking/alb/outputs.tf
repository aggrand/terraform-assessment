output "alb_dns_name" {
  value       = aws_lb.module_lb.dns_name
  description = "DNS name of the load balancer"
}
