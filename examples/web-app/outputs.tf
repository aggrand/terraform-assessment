output "dns_name" {
  description = "DNS name where the services is accessible"
  value       = module.web-app.dns_name
}
