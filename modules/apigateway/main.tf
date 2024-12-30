resource "aws_apigatewayv2_api" "http" {
  name          = "${var.system_name}-${var.env_type}-http-api-gateway"
  description   = "${var.system_name}-${var.env_type}-http-api-gateway"
  protocol_type = "HTTP"
  tags = {
    Name       = "${var.system_name}-${var.env_type}-http-api-gateway"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_apigatewayv2_integration" "http" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.dynamodb_handler_lambda_function_qualified_arn
  payload_format_version = "2.0"
}

resource "aws_lambda_permission" "http" {
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_function_name
  qualifier     = local.lambda_function_version
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*"
}

resource "aws_apigatewayv2_route" "get_all_items" {
  api_id             = aws_apigatewayv2_api.http.id
  authorization_type = "NONE"
  route_key          = "GET /items"
  target             = "integrations/${aws_apigatewayv2_integration.http.id}"
}

resource "aws_apigatewayv2_route" "get_an_item" {
  api_id             = aws_apigatewayv2_api.http.id
  authorization_type = "NONE"
  route_key          = "GET /items/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.http.id}"
}

resource "aws_apigatewayv2_route" "delete_an_item" {
  api_id             = aws_apigatewayv2_api.http.id
  authorization_type = "NONE"
  route_key          = "DELETE /items/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.http.id}"
}

resource "aws_apigatewayv2_route" "create_or_update_an_item" {
  api_id             = aws_apigatewayv2_api.http.id
  authorization_type = "NONE"
  route_key          = "PUT /items"
  target             = "integrations/${aws_apigatewayv2_integration.http.id}"
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
  name        = "production"
  description = "Production stage for ${aws_apigatewayv2_api.http.name}"
  api_id      = aws_apigatewayv2_api.http.id
  auto_deploy = true
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
  tags = {
    Name       = "${aws_apigatewayv2_api.http.name}-production"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
