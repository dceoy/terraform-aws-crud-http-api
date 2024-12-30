resource "docker_image" "primary" {
  for_each     = local.docker_image_primary_names
  name         = each.value
  force_remove = var.docker_image_force_remove
  keep_locally = true
  dynamic "build" {
    for_each = var.docker_image_build ? [true] : []
    content {
      target     = lookup(var.docker_image_build_targets, each.key, null)
      context    = lookup(var.docker_image_build_contexts, each.key, null)
      dockerfile = lookup(var.docker_image_build_dockerfiles, each.key, null)
      build_args = lookup(var.docker_image_build_build_args, each.key, {})
      platform   = var.docker_image_build_platform
    }
  }
  triggers = {
    primary_image_name = each.value
  }
}

resource "docker_tag" "secondary" {
  depends_on   = [docker_image.primary]
  for_each     = local.docker_image_secondary_tag_sources
  source_image = each.value
  target_image = each.key
}

resource "docker_registry_image" "primary" {
  depends_on    = [docker_tag.secondary]
  for_each      = docker_image.primary
  name          = each.value.name
  keep_remotely = true
  triggers = {
    primary_image_name = each.value.name
  }
}

resource "docker_registry_image" "secondary" {
  depends_on    = [docker_registry_image.primary]
  for_each      = local.docker_image_secondary_tag_sources
  name          = each.key
  keep_remotely = true
  triggers = {
    primary_image_name   = each.value
    secondary_image_name = each.key
  }
}
