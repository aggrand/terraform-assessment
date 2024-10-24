variable "bucket_name" {
  description = "The name of the bucket to create"
  type        = string
}

variable "enable_logging" {
  description = "Whether to enable logging to a bucket"
  type        = bool
}

variable "logging_bucket" {
  description = "Bucket to log to"
  type        = string
}
