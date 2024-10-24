variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}

variable "subnet_ids" {
  description = "The subnets to attach to the ALB"
  type        = list(string)
}
