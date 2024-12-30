data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  lambda_image_uris = {
    connect-handler     = var.connect_handler_lambda_image_uri
    disconnect-handler  = var.disconnect_handler_lambda_image_uri
    sendmessage-handler = var.sendmessage_handler_lambda_image_uri
    default-handler     = var.default_handler_lambda_image_uri
  }
  lambda_function_names = {
    for k, v in local.lambda_image_uris : k => split(":", split("/", v)[length(split("/", v)) - 1])[0]
  }
}
