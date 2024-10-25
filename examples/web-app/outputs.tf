output "dns_name" {
  description = "DNS name where the services is accessible"
  value       = module.web-app.dns_name
}

output "db_address" {
  description = "Address of the db"
  value       = module.web-app.db_address
}

output "db_port" {
  description = "Port of the db"
  value       = module.web-app.db_port
}
