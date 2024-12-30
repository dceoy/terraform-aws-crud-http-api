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

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "dynamodb_hash_key" {
  description = "Attribute to use as the hash (partition) key for the DynamoDB table"
  type        = string
  default     = "id"
}

variable "dynamodb_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity for DynamoDB"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = var.dynamodb_billing_mode == "PROVISIONED" || var.dynamodb_billing_mode == "PAY_PER_REQUEST"
    error_message = "Invalid billing mode. Must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "dynamodb_read_capacity" {
  description = "Number of read units for the index for the provisioned mode of DynamoDB"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Number of write units for the index for the provisioned mode of DynamoDB"
  type        = number
  default     = 5
}

variable "dynamodb_point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery options for DynamoDB"
  type        = bool
  default     = false
}

variable "dynamodb_table_class" {
  description = "Storage class of the DynamoDB table"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = var.dynamodb_table_class == "STANDARD" || var.dynamodb_table_class == "STANDARD_INFREQUENT_ACCESS"
    error_message = "Invalid table class. Must be either STANDARD or STANDARD_INFREQUENT_ACCESS"
  }
}
