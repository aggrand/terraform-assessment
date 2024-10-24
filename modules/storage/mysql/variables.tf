variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "multi_az" {
  description = "Whether to deploy to multiple AZs for higher availability"
  type        = string
  default     = true
}

variable "db_name" {
  description = "The name of the db to create"
  type        = string
}

variable "db_username" {
  description = "The username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}
