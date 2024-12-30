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

variable "create_kms_key" {
  description = "Whether to create a KMS key"
  type        = bool
  default     = true
}

variable "kms_key_deletion_window_in_days" {
  description = "The duration in days after which the key is deleted after destruction of the resource"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_key_deletion_window_in_days >= 7 && var.kms_key_deletion_window_in_days <= 30
    error_message = "The deletion window must be between 7 and 30 days"
  }
}

variable "kms_key_rotation_period_in_days" {
  description = "The number of days after which AWS KMS rotates the key"
  type        = number
  default     = 365
  validation {
    condition     = var.kms_key_rotation_period_in_days >= 90 && var.kms_key_rotation_period_in_days <= 2560
    error_message = "The rotation period must be between 90 and 2560 days"
  }
}
