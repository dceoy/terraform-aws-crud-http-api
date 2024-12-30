output "docker_registry_primary_image_uris" {
  description = "Docker registry primary image URIs"
  value       = { for k, v in docker_registry_image.primary : k => v.name }
}

output "docker_registry_primary_image_ids" {
  description = "Docker registry primary image IDs"
  value       = { for k, v in docker_registry_image.primary : k => v.id }
}

output "docker_registry_secondary_image_uris" {
  description = "Docker registry secondary image URIs"
  value       = values(docker_registry_image.secondary)[*].name
}

output "docker_registry_secondary_image_ids" {
  description = "Docker registry secondary image IDs"
  value       = values(docker_registry_image.secondary)[*].id
}
