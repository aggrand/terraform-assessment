output "dns_name" {
  description = "DNS name where the services is accessible"
  value       = module.alb.alb_dns_name
}

output "db_address" {
  description = "Address of the db"
  value       = module.db.address
}

output "db_port" {
  description = "Port of the db"
  value       = module.db.port
}
