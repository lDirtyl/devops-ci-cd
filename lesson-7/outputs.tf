output "s3_bucket_name" {
  description = "Name of S3 bucket for states"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of DynamoDB table for state locking"
  value       = module.s3_backend.dynamodb_table_name
}