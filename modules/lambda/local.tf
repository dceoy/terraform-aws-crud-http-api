locals {
  lambda_function_names = {
    for k, v in var.lambda_image_uris : k => split(":", split("/", v)[length(split("/", v)) - 1])[0]
  }
  lambda_alias_name = var.lambda_alias_name != null ? var.lambda_alias_name : var.env_type
}
