variable "system_name" {
  description = "System name"
  type        = string
  default     = "slc"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "lambda_function_qualified_arn" {
  description = "Lambda function qualified ARN of the DynamoDB handler"
  type        = string
}

variable "lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN of the DynamoDB handler"
  type        = string
}

variable "lambda_permission_principal_org_id" {
  description = "Organization ID for the Lambda permission principal"
  type        = string
  default     = null
}

variable "apigateway_api_version" {
  description = "Version identifier for the API Gateway"
  type        = string
  default     = null
}

variable "apigateway_api_disable_execute_api_endpoint" {
  description = "Whether to disable the default execute-api endpoint of the API Gateway"
  type        = bool
  default     = null
}

variable "apigateway_api_cors_configuration" {
  description = "CORS (Cross-Origin Resource Sharing) configuration for the API Gateway"
  type        = map(any)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.apigateway_api_cors_configuration) : contains(["allow_credentials", "allow_headers", "allow_methods", "allow_origins", "expose_headers", "max_age"], k)])
    error_message = "API Gateway CORS configuration allows only allow_credentials, allow_headers, allow_methods, allow_origins, expose_headers and max_age as keys"
  }
}

variable "apigateway_integration_timeout_milliseconds" {
  description = "Custom timeout for the API Gateway integration"
  type        = number
  default     = 30000
  validation {
    condition     = var.apigateway_integration_timeout_milliseconds >= 50 && var.apigateway_integration_timeout_milliseconds <= 30000
    error_message = "Custom timeout must be between 50 and 30,000 milliseconds"
  }
}

variable "apigateway_integration_request_parameters" {
  description = "Key-value map specifying how to transform HTTP requests before sending them to the backend in the API Gateway integration"
  type        = map(string)
  default     = {}
}

variable "apigateway_integration_tls_config_server_name_to_verify" {
  description = "Server name to verify for the API Gateway integration TLS configuration"
  type        = string
  default     = null
}

variable "apigateway_route_authorization_type" {
  description = "Authorization type for the API Gateway routes"
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["NONE", "JWT", "AWS_IAM", "CUSTOM"], var.apigateway_route_authorization_type)
    error_message = "Authorization type for the route must be NONE, JWT, AWS_IAM or CUSTOM"
  }
}

variable "apigateway_route_authorization_scopes" {
  description = "Authorization scopes used with a JWT authorizer to authorize the method invocation in the API Gateway routes"
  type        = list(string)
  default     = null
}

variable "apigateway_route_authorizer_id" {
  description = "Identifier of the authorizer resource to be associated with the API Gateway routes"
  type        = string
  default     = null
}

variable "apigateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "production"
}

variable "apigateway_stage_stage_variables" {
  description = "Stage variables for the API Gateway stage"
  type        = map(string)
  default     = null
}

variable "apigateway_stage_default_route_settings_detailed_metrics_enabled" {
  description = "Whether to enable detailed metrics for the default route of the API Gateway stage"
  type        = bool
  default     = null
}

variable "apigateway_stage_default_route_settings_throttling_burst_limit" {
  description = "Throttling burst limit for the default route of the API Gateway stage"
  type        = number
  default     = null
}

variable "apigateway_stage_default_route_settings_throttling_rate_limit" {
  description = "Throttling rate limit for the default route of the API Gateway stage"
  type        = number
  default     = null
}


variable "apigateway_stage_route_settings" {
  description = "Route settings for the API Gateway stage (key: route key, value: map of detailed_metrics_enabled, throttling_burst_limit, throttling_rate_limit)"
  type        = map(map(string))
  default     = {}
  validation {
    condition     = alltrue([for m in values(var.apigateway_stage_route_settings) : alltrue([for k in keys(m) : contains(["detailed_metrics_enabled", "throttling_burst_limit", "throttling_rate_limit"], k)])])
    error_message = "API Gateway stage route settings allow only detailed_metrics_enabled, throttling_burst_limit and throttling_rate_limit as keys"
  }
}
