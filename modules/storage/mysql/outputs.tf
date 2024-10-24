output "address" {
  value       = aws_db_instance.module_db.address
  description = "Address of the db"
}

output "port" {
  value       = aws_db_instance.module_db.port
  description = "Port of the db"
}
