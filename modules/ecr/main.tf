# trivy:ignore:avd-aws-0031
# trivy:ignore:avd-aws-0033
resource "aws_ecr_repository" "containers" {
  #checkov:skip=CKV_AWS_51:Mutable tags allow the build pipeline to republish the same primary tag on a rebuild.
  #checkov:skip=CKV_AWS_136:AWS-managed AES256 encryption is intentionally used; customer-managed ECR keys are optional.
  for_each             = var.ecr_repository_names
  name                 = each.value
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = {
    Name       = each.value
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_ecr_lifecycle_policy" "containers" {
  for_each   = aws_ecr_repository.containers
  repository = each.value.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep images with sematic versioning"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*.*.*", "v*.*.*"]
          countType      = "imageCountMoreThan"
          countNumber    = var.ecr_lifecycle_policy_semver_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep tagged images"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "imageCountMoreThan"
          countNumber    = var.ecr_lifecycle_policy_any_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Remove untagged images"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.ecr_lifecycle_policy_untagged_image_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
