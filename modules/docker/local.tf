data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  docker_image_primary_names = {
    for k, v in var.ecr_repository_urls : k => "${v}:${var.docker_image_primary_tag}"
  }
  docker_image_secondary_tag_sources = merge(
    [
      for t in var.ecr_image_secondary_tags : {
        for k, v in var.ecr_repository_urls : "${v}:${t}" => local.docker_image_primary_names[k]
      }
    ]...
  )
}

data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  host = var.docker_host
  registry_auth {
    address  = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}
