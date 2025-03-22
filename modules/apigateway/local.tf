locals {
  lambda_function_name    = split(":", var.lambda_function_qualified_arn)[6]
  lambda_function_version = endswith(var.lambda_function_qualified_arn, ":$LATEST") ? null : split(":", var.lambda_function_qualified_arn)[7]
}
