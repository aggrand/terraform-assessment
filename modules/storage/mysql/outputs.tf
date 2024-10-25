output "address" {
  description = "Address of the db"
  value       = aws_db_instance.module_db.address
}

output "port" {
  description = "Port of the db"
  value       = aws_db_instance.module_db.port
}

output "db_sg_id" {
  description = "ID of the security group of the database"
  value       = aws_security_group.db.id
}
