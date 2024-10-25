output "dns_name" {
  description = "DNS name where the services is accessible"
  value       = module.alb.alb_dns_name
}
