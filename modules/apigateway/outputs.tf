output "apigateway_api_id" {
  description = "API Gateway API ID"
  value       = aws_apigatewayv2_api.http.id
}

output "apigateway_api_endpoint" {
  description = "API Gateway API endpoint"
  value       = aws_apigatewayv2_api.http.api_endpoint
}

output "apigateway_lambda_integration_id" {
  description = "API Gateway integration ID for Lambda"
  value       = aws_apigatewayv2_integration.http.id
}

output "apigateway_get_all_items_route_id" {
  description = "API Gateway route ID for get_all_items route"
  value       = aws_apigatewayv2_route.get_all_items.id
}

output "apigateway_get_an_item_route_id" {
  description = "API Gateway route ID for get_an_item route"
  value       = aws_apigatewayv2_route.get_an_item.id
}

output "apigateway_delete_an_item_route_id" {
  description = "API Gateway route ID for delete_an_item route"
  value       = aws_apigatewayv2_route.delete_an_item.id
}

output "apigateway_create_or_update_an_item_route_id" {
  description = "API Gateway route ID for create_or_update_an_item route"
  value       = aws_apigatewayv2_route.create_or_update_an_item.id
}

output "apigateway_api_stage_id" {
  description = "API Gateway API stage ID"
  value       = aws_apigatewayv2_stage.http.id
}

output "apigateway_api_stage_invoke_url" {
  description = "API Gateway API stage invoke URL"
  value       = aws_apigatewayv2_stage.http.invoke_url
}

output "apigateway_cloudwatch_log_group_name" {
  description = "API Gateway CloudWatch log group name"
  value       = aws_cloudwatch_log_group.http.name
}
