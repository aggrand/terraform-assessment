output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS of the load balancer"
}
