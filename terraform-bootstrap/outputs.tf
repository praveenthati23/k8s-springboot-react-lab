output "state_bucket_name" {
  description = "S3 bucket name to use as the backend bucket in later stages"
  value       = aws_s3_bucket.tf_state.id
}

output "lock_table_name" {
  description = "DynamoDB table name to use as the backend lock table in later stages"
  value       = aws_dynamodb_table.tf_lock.id
}

output "aws_region" {
  description = "Region these backend resources live in"
  value       = var.aws_region
}
