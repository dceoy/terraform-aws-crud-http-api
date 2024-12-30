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

variable "ecr_repository_names" {
  description = "ECR repository names"
  type        = map(string)
  default     = {}
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_force_delete" {
  description = "Whether to delete the ECR repository and all images in it"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy_semver_image_count" {
  description = "Semantic versioning image count to keep by ECR lifecycle policy"
  type        = number
  default     = 9999
}

variable "ecr_lifecycle_policy_any_image_count" {
  description = "Any image count to keep by ECR lifecycle policy"
  type        = number
  default     = 10
}

variable "ecr_lifecycle_policy_untagged_image_days" {
  description = "Untagged image days to keep by ECR lifecycle policy"
  type        = number
  default     = 7
}
