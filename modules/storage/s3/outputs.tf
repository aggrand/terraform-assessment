output "bucket_arn" {
  value       = aws_s3_bucket.module_bucket.arn
  description = "ARN of the bucket created"
}

output "bucket_id" {
  value       = aws_s3_bucket.module_bucket.id
  description = "ID of the bucket created"
}
