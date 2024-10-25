output "address" {
  description = "Address of the db"
  value       = aws_db_instance.module_db.address
}

output "port" {
  description = "Port of the db"
  value       = aws_db_instance.module_db.port
}
