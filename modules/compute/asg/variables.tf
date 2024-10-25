variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "instance_ami" {
  description = "The AMI for instances"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
}

variable "user_data" {
  description = "The userdata for instances"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "The IDs of the subnets to place the asg into"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "min_size" {
  description = "The minimum number of instances to have in the cluster"
  type        = string
  default     = 2
}

variable "max_size" {
  description = "The maximum number of instances to have in the cluster"
  type        = string
  default     = 5
}
