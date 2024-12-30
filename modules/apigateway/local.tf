data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  lambda_function_name    = split(":", var.dynamodb_handler_lambda_function_qualified_arn)[6]
  lambda_function_version = endswith(var.dynamodb_handler_lambda_function_qualified_arn, ":$LATEST") ? null : split(":", var.dynamodb_handler_lambda_function_qualified_arn)[7]
}