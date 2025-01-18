output "dynamodb_table_id" {
  description = "DynamoDB table ID"
  value       = aws_dynamodb_table.db.id
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.db.arn
}

output "dynamodb_table_stream_arn" {
  description = "DynamoDB table Stream ARN"
  value       = aws_dynamodb_table.db.stream_arn
}

output "dynamodb_table_stream_label" {
  description = "Timestamp in ISO 8601 format of the DynamoDB table Stream"
  value       = aws_dynamodb_table.db.stream_label
}
