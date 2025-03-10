variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity for DynamoDB"
  type        = string
  default     = "PROVISIONED"
  validation {
    condition     = var.dynamodb_billing_mode == "PROVISIONED" || var.dynamodb_billing_mode == "PAY_PER_REQUEST"
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST"
  }
}

variable "dynamodb_hash_key" {
  description = "Attribute to use as the partition (hash) key for the DynamoDB table"
  type        = string
  default     = "id"
}

variable "dynamodb_range_key" {
  description = "Attribute to use as the sort (range) key for the DynamoDB table"
  type        = string
  default     = null
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

variable "dynamodb_stream_enabled" {
  description = "Whether to enable DynamoDB Streams for the table"
  type        = bool
  default     = false
}

variable "dynamodb_stream_view_type" {
  description = "StreamViewType for DynamoDB Streams"
  type        = string
  default     = null
  validation {
    condition     = var.dynamodb_stream_view_type == null || var.dynamodb_stream_view_type == "KEYS_ONLY" || var.dynamodb_stream_view_type == "NEW_IMAGE" || var.dynamodb_stream_view_type == "OLD_IMAGE" || var.dynamodb_stream_view_type == "NEW_AND_OLD_IMAGES"
    error_message = "Stream view type must be KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES"
  }
}

variable "dynamodb_table_class" {
  description = "Storage class of the DynamoDB table"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = var.dynamodb_table_class == "STANDARD" || var.dynamodb_table_class == "STANDARD_INFREQUENT_ACCESS"
    error_message = "Table class must be STANDARD or STANDARD_INFREQUENT_ACCESS"
  }
}

variable "dynamodb_deletion_protection_enabled" {
  description = "Whether to enable deletion protection for the DynamoDB table"
  type        = bool
  default     = null
}

variable "dynamodb_restore_date_time" {
  description = "Time of the point-in-time recovery point to restore for the DynamoDB table"
  type        = string
  default     = null
}

variable "dynamodb_restore_source_name" {
  description = "Name of the source DynamoDB table to restore"
  type        = string
  default     = null
}

variable "dynamodb_restore_source_table_arn" {
  description = "ARN of the source DynamoDB table to restore"
  type        = string
  default     = null
}

variable "dynamodb_restore_to_latest_time" {
  description = "Whether to restore the DynamoDB table to the most recent point-in-time recovery point"
  type        = bool
  default     = null
}

variable "dynamodb_attributes" {
  description = "Attributes for the DynamoDB table (key: name, value: type)"
  type        = map(string)
  default     = { "id" = "S" }
  validation {
    condition     = length(var.dynamodb_attributes) > 0 && alltrue([for v in values(var.dynamodb_attributes) : contains(["S", "N", "B"], v)])
    error_message = "DynamoDB attributes must be a non-empty map with values of either S, N, or B"
  }
}

variable "dynamodb_ttl_attribute_name" {
  description = "DynamoDB table attribute to store the TTL timestamp in"
  type        = string
  default     = null
}

variable "dynamodb_point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery options for DynamoDB"
  type        = bool
  default     = false
}

variable "dynamodb_local_secondary_indexes" {
  description = "Local secondary indexes (LSIs) for the DynamoDB table (key: name, value: map of range_key, projection_type, non_key_attributes)"
  type        = map(map(string))
  default     = {}
  validation {
    condition     = alltrue([for m in values(var.dynamodb_local_secondary_indexes) : alltrue([for k in keys(m) : contains(["range_key", "projection_type", "non_key_attributes"], k)])])
    error_message = "Local secondary indexes' map values allow only range_key, projection_type, and non_key_attributes as keys"
  }
}

variable "dynamodb_global_secondary_indexes" {
  description = "Global secondary indexes (GSIs) for the DynamoDB table (key: name, value: map of hash_key, projection_type, range_key, read_capacity, write_capacity, non_key_attributes, on_demand_throughput_max_read_request_units, on_demand_throughput_max_write_request_units)"
  type        = map(map(any))
  default     = {}
  validation {
    condition     = alltrue([for m in values(var.dynamodb_global_secondary_indexes) : alltrue([for k in keys(m) : contains(["hash_key", "projection_type", "range_key", "read_capacity", "write_capacity", "non_key_attributes", "on_demand_throughput_max_read_request_units", "on_demand_throughput_max_write_request_units"], k)])])
    error_message = "Global secondary indexes' map values allow only hash_key, projection_type, range_key, read_capacity, write_capacity, non_key_attributes, on_demand_throughput_max_read_request_units, and on_demand_throughput_max_write_request_units as keys"
  }
}

variable "dynamodb_replica_regions" {
  description = "Replica regions for the global DynamoDB table (key: region, value: map of kms_key_arn, propagate_tags, point_in_time_recovery)"
  type        = map(map(any))
  default     = {}
  validation {
    condition     = alltrue([for m in var.dynamodb_replica_regions : alltrue([for k in keys(m) : contains(["kms_key_arn", "propagate_tags", "point_in_time_recovery"], k)])])
    error_message = "Replica regions' map values allow only kms_key_arn, propagate_tags, and point_in_time_recovery as keys"
  }
}

variable "dynamodb_import_table" {
  description = "Configurations for importing S3 data into the DynamoDB table (key: input_format, input_compression_type, s3_bucket_source_bucket, s3_bucket_source_bucket_owner, s3_bucket_source_key_prefix, input_format_options_csv_delimiter, input_format_options_csv_header_list)"
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.dynamodb_import_table) : contains(["input_format", "input_compression_type", "s3_bucket_source_bucket", "s3_bucket_source_bucket_owner", "s3_bucket_source_key_prefix", "input_format_options_csv_delimiter", "input_format_options_csv_header_list"], k)])
    error_message = "Import table allows only input_format, input_compression_type, s3_bucket_source_bucket, s3_bucket_source_bucket_owner, s3_bucket_source_key_prefix, input_format_options_csv_delimiter, and input_format_options_csv_header_list as keys"
  }
}

variable "dynamodb_on_demand_throughput_max_read_request_units" {
  description = "Maximum read request units for the on-demand DynamoDB table"
  type        = number
  default     = null
}

variable "dynamodb_on_demand_throughput_max_write_request_units" {
  description = "Maximum write request units for the on-demand DynamoDB table"
  type        = number
  default     = null
}
