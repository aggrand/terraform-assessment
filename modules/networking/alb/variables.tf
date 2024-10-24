# TODO: Turn this into an app name and we can add -alb after?
variable "alb_name" {
  description = "The name of the ALB"
  type        = string
}

# TODO: Validate that they're nonzero?
variable "subnet_ids" {
  description = "The subnets to attach to the ALB"
  type        = list(string)
}
