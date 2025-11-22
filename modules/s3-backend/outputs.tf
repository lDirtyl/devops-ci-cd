# output "s3_bucket_name" {
#   description = "Name of S3 bucket for states"
#   value = aws_s3_bucket.terraform_state.bucket
# }
#
# output "bucket_arn" {
#   description = "S3 bucket ARN"
#   value = aws_s3_bucket.terraform_state.arn
# }
#
# output "dynamodb_table_name" {
#   description = "Name of DynamoDB table for state locking"
#   value = aws_dynamodb_table.terraform_locks.name
# }
#
# output "dynamodb_table_arn" {
#   description = "DynamoDB table ARN"
#   value = aws_dynamodb_table.terraform_locks.arn
# }