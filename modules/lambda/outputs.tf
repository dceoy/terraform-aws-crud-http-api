output "lambda_function_names" {
  description = "Lambda function names"
  value       = { for k, v in aws_lambda_function.functions : k => v.function_name }
}

output "lambda_function_qualified_arns" {
  description = "Lambda function qualified ARNs"
  value       = { for k, v in aws_lambda_function.functions : k => v.qualified_arn }
}

output "lambda_function_versions" {
  description = "Lambda function versions"
  value       = { for k, v in aws_lambda_function.functions : k => v.version }
}

output "lambda_function_invoke_arns" {
  description = "Lambda function invoke ARNs"
  value       = { for k, v in aws_lambda_function.functions : k => v.invoke_arn }
}

output "lambda_iam_role_arns" {
  description = "Lambda IAM role ARNs"
  value       = { for k, v in aws_iam_role.functions : k => v.arn }
}

output "lambda_cloudwatch_logs_log_group_names" {
  description = "Lambda CloudWatch Logs log group names"
  value       = { for k, v in aws_cloudwatch_log_group.functions : k => v.name }
}
