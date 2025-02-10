variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
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

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "lambda_image_uris" {
  description = "Container image URIs for Lambda (key: arbitrary key, value: image URI)"
  type        = map(string)
  default     = {}
}

variable "lambda_architectures" {
  description = "Lambda instruction set architectures"
  type        = list(string)
  default     = ["x86_64"]
  validation {
    condition     = alltrue([for a in var.lambda_architectures : contains(["x86_64", "arm64"], a)])
    error_message = "Lambda architectures must be x86_64 or arm64"
  }
}

variable "lambda_memory_sizes" {
  description = "Lambda memory sizes in MB (key: arbitrary key, value: memory size)"
  type        = map(number)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.lambda_memory_sizes : v >= 128 && v <= 10240])
    error_message = "Lambda memory sizes must be between 128 and 10240"
  }
}

variable "lambda_timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 3
}

variable "lambda_reserved_concurrent_executions" {
  description = "Lambda reserved concurrent executions"
  type        = number
  default     = -1
  validation {
    condition     = var.lambda_reserved_concurrent_executions == -1 || var.lambda_reserved_concurrent_executions >= 0
    error_message = "Lambda reserved concurrent executions must be -1 or greater"
  }
}

variable "lambda_logging_config_log_format" {
  description = "Lambda logging config log format"
  type        = string
  default     = "Text"
  validation {
    condition     = var.lambda_logging_config_log_format == "Text" || var.lambda_logging_config_log_format == "JSON"
    error_message = "Lambda logging config log format must be either Text or JSON"
  }
}

variable "lambda_logging_config_application_log_level" {
  description = "Lambda logging config application log level"
  type        = string
  default     = "INFO"
  validation {
    condition     = var.lambda_logging_config_application_log_level == "TRACE" || var.lambda_logging_config_application_log_level == "DEBUG" || var.lambda_logging_config_application_log_level == "INFO" || var.lambda_logging_config_application_log_level == "WARN" || var.lambda_logging_config_application_log_level == "ERROR" || var.lambda_logging_config_application_log_level == "FATAL"
    error_message = "Lambda logging config application log level must be either TRACE, DEBUG, INFO, WARN, ERROR, or FATAL"
  }
}

variable "lambda_logging_config_system_log_level" {
  description = "Lambda logging config system log level"
  type        = string
  default     = "INFO"
  validation {
    condition     = var.lambda_logging_config_system_log_level == "DEBUG" || var.lambda_logging_config_system_log_level == "INFO" || var.lambda_logging_config_system_log_level == "WARN"
    error_message = "Lambda logging config system log level must be either DEBUG, INFO, or WARN"
  }
}

variable "lambda_ephemeral_storage_sizes" {
  description = "Lambda ephemeral storage (/tmp) sizes in MB (key: arbitrary key, value: storage size)"
  type        = map(number)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.lambda_ephemeral_storage_sizes : v >= 512 && v <= 10240])
    error_message = "Lambda ephemeral storage sizes must be between 512 and 10240"
  }
}

variable "lambda_environment_variables" {
  description = "Lambda environment variables (key: arbitrary key, value: map of environment variables)"
  type        = map(map(string))
  default     = {}
}

variable "lambda_image_config_entry_points" {
  description = "Lambda image config entry points (key: arbitrary key, value: list of entry points)"
  type        = map(list(string))
  default     = {}

}
variable "lambda_image_config_commands" {
  description = "Lambda image config commands (key: arbitrary key, value: list of commands)"
  type        = map(list(string))
  default     = {}
}

variable "lambda_image_config_working_directories" {
  description = "Lambda image config working directories (key: arbitrary key, value: working directory)"
  type        = map(string)
  default     = {}
}

variable "lambda_tracing_config_mode" {
  description = "Lambda tracing config mode"
  type        = string
  default     = "Active"
  validation {
    condition     = var.lambda_tracing_config_mode == "PassThrough" || var.lambda_tracing_config_mode == "Active"
    error_message = "Lambda tracing config mode must be either PassThrough or Active"
  }
}

variable "lambda_provisioned_concurrent_executions" {
  description = "Lambda provisioned concurrent executions"
  type        = number
  default     = -1
  validation {
    condition     = var.lambda_provisioned_concurrent_executions == -1 || var.lambda_provisioned_concurrent_executions >= 0
    error_message = "Lambda provisioned concurrent executions must be -1 or greater"
  }
}
