resource "aws_apigatewayv2_api" "http" {
  name                         = "${var.system_name}-${var.env_type}-http-api-gateway"
  description                  = "HTTP API Gateway for ${local.lambda_function_name}"
  protocol_type                = "HTTP"
  route_selection_expression   = "$request.method $request.path"
  version                      = var.apigateway_api_version
  disable_execute_api_endpoint = var.apigateway_api_disable_execute_api_endpoint
  dynamic "cors_configuration" {
    for_each = length(var.apigateway_api_cors_configuration) > 0 ? [true] : []
    content {
      allow_credentials = lookup(cors_configuration.value, "allow_credentials", null)
      allow_headers     = lookup(cors_configuration.value, "allow_headers", null)
      allow_methods     = lookup(cors_configuration.value, "allow_methods", null)
      allow_origins     = lookup(cors_configuration.value, "allow_origins", null)
      expose_headers    = lookup(cors_configuration.value, "expose_headers", null)
      max_age           = lookup(cors_configuration.value, "max_age", null)
    }
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-http-api-gateway"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_apigatewayv2_integration" "http" {
  description            = "HTTP API Gateway integration for ${local.lambda_function_name}"
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_function_invoke_arn
  payload_format_version = "2.0"
  request_parameters     = var.apigateway_integration_request_parameters
  timeout_milliseconds   = var.apigateway_integration_timeout_milliseconds
  dynamic "tls_config" {
    for_each = var.apigateway_integration_tls_config_server_name_to_verify != null ? [true] : []
    content {
      server_name_to_verify = var.apigateway_integration_tls_config_server_name_to_verify
    }
  }
}

resource "aws_apigatewayv2_route" "get_all_items" {
  operation_name       = "GetAllItems"
  api_id               = aws_apigatewayv2_api.http.id
  route_key            = "GET /items"
  target               = "integrations/${aws_apigatewayv2_integration.http.id}"
  authorization_type   = var.apigateway_route_authorization_type
  authorization_scopes = var.apigateway_route_authorization_scopes
  authorizer_id        = var.apigateway_route_authorizer_id
}

resource "aws_apigatewayv2_route" "get_an_item" {
  operation_name       = "GetAnItem"
  api_id               = aws_apigatewayv2_api.http.id
  route_key            = "GET /items/{id}"
  target               = "integrations/${aws_apigatewayv2_integration.http.id}"
  authorization_type   = var.apigateway_route_authorization_type
  authorization_scopes = var.apigateway_route_authorization_scopes
  authorizer_id        = var.apigateway_route_authorizer_id
}

resource "aws_apigatewayv2_route" "delete_an_item" {
  operation_name       = "DeleteAnItem"
  api_id               = aws_apigatewayv2_api.http.id
  route_key            = "DELETE /items/{id}"
  target               = "integrations/${aws_apigatewayv2_integration.http.id}"
  authorization_type   = var.apigateway_route_authorization_type
  authorization_scopes = var.apigateway_route_authorization_scopes
  authorizer_id        = var.apigateway_route_authorizer_id
}

resource "aws_apigatewayv2_route" "create_or_update_an_item" {
  operation_name       = "CreateOrUpdateAnItem"
  api_id               = aws_apigatewayv2_api.http.id
  route_key            = "PUT /items"
  target               = "integrations/${aws_apigatewayv2_integration.http.id}"
  authorization_type   = var.apigateway_route_authorization_type
  authorization_scopes = var.apigateway_route_authorization_scopes
  authorizer_id        = var.apigateway_route_authorizer_id
}

resource "aws_lambda_permission" "http" {
  function_name       = local.lambda_function_name
  qualifier           = local.lambda_function_version
  statement_id_prefix = "${aws_apigatewayv2_api.http.id}-"
  action              = "lambda:InvokeFunction"
  principal           = "apigateway.amazonaws.com"
  principal_org_id    = var.lambda_permission_principal_org_id
  source_arn          = "${aws_apigatewayv2_api.http.execution_arn}/*"
}

# trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "http" {
  name              = "/${var.system_name}/${var.env_type}/apigateway/${aws_apigatewayv2_api.http.id}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/apigateway/${aws_apigatewayv2_api.http.id}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_apigatewayv2_stage" "http" {
  depends_on      = [aws_apigatewayv2_route.get_all_items, aws_apigatewayv2_route.get_an_item, aws_apigatewayv2_route.delete_an_item, aws_apigatewayv2_route.create_or_update_an_item]
  name            = var.apigateway_stage_name
  description     = "HTTP API Gateway ${var.apigateway_stage_name} stage for ${aws_apigatewayv2_api.http.name}"
  api_id          = aws_apigatewayv2_api.http.id
  auto_deploy     = true
  stage_variables = var.apigateway_stage_stage_variables
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.http.arn
    format = jsonencode({
      requestId         = "$context.requestId"
      extendedRequestId = "$context.extendedRequestId"
      ip                = "$context.identity.sourceIp"
      caller            = "$context.identity.caller"
      user              = "$context.identity.user"
      requestTime       = "$context.requestTime"
      httpMethod        = "$context.httpMethod"
      resourcePath      = "$context.resourcePath"
      status            = "$context.status"
      protocol          = "$context.protocol"
      responseLength    = "$context.responseLength"
    })
  }
  dynamic "default_route_settings" {
    for_each = var.apigateway_stage_default_route_settings_detailed_metrics_enabled != null || var.apigateway_stage_default_route_settings_throttling_burst_limit != null || var.apigateway_stage_default_route_settings_throttling_rate_limit != null ? [true] : []
    content {
      detailed_metrics_enabled = var.apigateway_stage_default_route_settings_detailed_metrics_enabled
      throttling_burst_limit   = var.apigateway_stage_default_route_settings_throttling_burst_limit
      throttling_rate_limit    = var.apigateway_stage_default_route_settings_throttling_rate_limit
    }
  }
  dynamic "route_settings" {
    for_each = var.apigateway_stage_route_settings
    content {
      route_key                = route_settings.key
      detailed_metrics_enabled = lookup(route_settings.value, "detailed_metrics_enabled", null)
      throttling_burst_limit   = lookup(route_settings.value, "throttling_burst_limit", null)
      throttling_rate_limit    = lookup(route_settings.value, "throttling_rate_limit", null)
    }
  }
  tags = {
    Name       = "${aws_apigatewayv2_api.http.name}-${var.apigateway_stage_name}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
