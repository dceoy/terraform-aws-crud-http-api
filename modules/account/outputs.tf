output "apigateway_account_api_key_version" {
  description = "API Gateway account API key version"
  value       = aws_api_gateway_account.apigateway.api_key_version
}

output "apigateway_account_features" {
  description = "API Gateway account features"
  value       = aws_api_gateway_account.apigateway.features
}

output "apigateway_account_throttle_settings" {
  description = "API Gateway account-level throttle settings"
  value       = aws_api_gateway_account.apigateway.throttle_settings
}

output "apigateway_account_iam_role_arn" {
  description = "API Gateway account IAM role ARN"
  value       = aws_api_gateway_account.apigateway.cloudwatch_role_arn
}
