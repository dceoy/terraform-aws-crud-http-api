variable "ecr_repository_urls" {
  description = "ECR repository URLs (key: arbitrary key, value: ECR repository URL)"
  type        = map(string)
  default     = {}
}

variable "ecr_image_secondary_tags" {
  description = "ECR image secondary tags"
  type        = list(string)
  default     = []
}

variable "docker_image_force_remove" {
  description = "Whether to remove the image forcibly when the resource is destroyed"
  type        = bool
  default     = false
}

variable "docker_image_build" {
  description = "Whether to build the Docker image"
  type        = bool
  default     = true
}

variable "docker_image_build_targets" {
  description = "Docker image build target stages (key: arbitrary key, value: target stage)"
  type        = map(string)
  default     = {}
}

variable "docker_image_build_contexts" {
  description = "Docker image build contexts (key: arbitrary key, value: build context)"
  type        = map(string)
  default     = {}
}

variable "docker_image_build_dockerfiles" {
  description = "Dockerfile names (key: arbitrary key, value: Dockerfile name)"
  type        = map(string)
  default     = {}
}

variable "docker_image_build_build_args" {
  description = "Docker image build-time variables (key: arbitrary key, value: map of build-time variables)"
  type        = map(map(string))
  default     = {}
}

variable "docker_image_build_platform" {
  description = "Docker image platform"
  type        = string
  default     = null
}

variable "docker_image_primary_tag" {
  description = "Docker image primary tag"
  type        = string
  default     = "latest"
}

variable "docker_host" {
  description = "Docker daemon address"
  type        = string
  default     = "unix:///var/run/docker.sock"
}
