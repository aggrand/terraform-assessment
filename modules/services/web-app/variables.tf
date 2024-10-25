variable "app_name" {
  description = "The name of the app to use for all cluster resources"
  type        = string
}

variable "instance_ami" {
  description = "The AMI to use for instances"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 instances"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances"
  type        = number
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
