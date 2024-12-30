output "dynamodb_handler_lambda_function_name" {
  description = "Lambda function name of the DynamoDB handler"
  value       = aws_lambda_function.functions["dynamodb-handler"].function_name
}

output "dynamodb_handler_lambda_function_qualified_arn" {
  description = "Lambda function qualified ARN of the DynamoDB handler"
  value       = aws_lambda_function.functions["dynamodb-handler"].qualified_arn
}

output "dynamodb_handler_lambda_function_version" {
  description = "Lambda function version of the DynamoDB handler"
  value       = aws_lambda_function.functions["dynamodb-handler"].version
}

output "dynamodb_handler_lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN of the DynamoDB handler"
  value       = aws_lambda_function.functions["dynamodb-handler"].invoke_arn
}

output "dynamodb_handler_lambda_iam_role_arn" {
  description = "Lambda IAM role ARN of the DynamoDB handler"
  value       = aws_iam_role.functions["dynamodb-handler"].arn
}

output "dynamodb_handler_lambda_cloudwatch_logs_log_group_name" {
  description = "Lambda CloudWatch Logs log group name of the DynamoDB handler"
  value       = aws_cloudwatch_log_group.functions["dynamodb-handler"].name
}
