resource "aws_lambda_function" "functions" {
  for_each                       = aws_iam_role.functions
  function_name                  = local.lambda_function_names[each.key]
  description                    = "Lambda function for ${each.key}"
  role                           = each.value.arn
  package_type                   = "Image"
  image_uri                      = var.lambda_image_uris[each.key]
  architectures                  = var.lambda_architectures
  memory_size                    = var.lambda_memory_sizes[each.key]
  timeout                        = var.lambda_timeout
  reserved_concurrent_executions = var.lambda_reserved_concurrent_executions
  publish                        = true
  logging_config {
    log_group             = aws_cloudwatch_log_group.functions[each.key].name
    log_format            = var.lambda_logging_config_log_format
    application_log_level = var.lambda_logging_config_log_format == "Text" ? null : var.lambda_logging_config_application_log_level
    system_log_level      = var.lambda_logging_config_log_format == "Text" ? null : var.lambda_logging_config_system_log_level
  }
  tracing_config {
    mode = var.lambda_tracing_config_mode
  }
  dynamic "ephemeral_storage" {
    for_each = lookup(var.lambda_ephemeral_storage_sizes, each.key, null) != null ? [true] : []
    content {
      size = lookup(var.lambda_ephemeral_storage_sizes, each.key, null)
    }
  }
  dynamic "image_config" {
    for_each = lookup(var.lambda_image_config_entry_points, each.key, null) != null || lookup(var.lambda_image_config_commands, each.key, null) != null || lookup(var.lambda_image_config_working_directories, each.key, null) != null ? [true] : []
    content {
      entry_point       = lookup(var.lambda_image_config_entry_points, each.key, null)
      command           = lookup(var.lambda_image_config_commands, each.key, null)
      working_directory = lookup(var.lambda_image_config_working_directories, each.key, null)
    }
  }
  dynamic "environment" {
    for_each = lookup(var.lambda_environment_variables, each.key, null) != null ? [true] : []
    content {
      variables = lookup(var.lambda_environment_variables, each.key, null)
    }
  }
  dynamic "vpc_config" {
    for_each = length(var.lambda_vpc_config_subnet_ids) > 0 && length(var.lambda_vpc_config_security_group_ids) > 0 ? [true] : []
    content {
      subnet_ids                  = var.lambda_vpc_config_subnet_ids
      security_group_ids          = var.lambda_vpc_config_security_group_ids
      ipv6_allowed_for_dual_stack = var.lambda_vpc_config_ipv6_allowed_for_dual_stack
    }
  }
  tags = {
    Name       = local.lambda_function_names[each.key]
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

# trivy:ignore:avd-aws-0017
resource "aws_cloudwatch_log_group" "functions" {
  for_each          = local.lambda_function_names
  name              = "/${var.system_name}/${var.env_type}/lambda/${each.value}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/lambda/${each.value}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_lambda_alias" "functions" {
  for_each         = aws_lambda_function.functions
  name             = local.lambda_alias_name
  description      = "Alias for the latest version of ${each.value.function_name}"
  function_name    = each.value.function_name
  function_version = each.value.version
}

resource "aws_lambda_provisioned_concurrency_config" "functions" {
  for_each                          = var.lambda_provisioned_concurrent_executions > -1 && length(aws_lambda_function.functions) > 0 ? aws_lambda_function.functions : {}
  function_name                     = each.value.function_name
  qualifier                         = aws_lambda_alias.functions[each.key].name
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions
  skip_destroy                      = false
}

resource "aws_iam_role" "functions" {
  for_each              = local.lambda_function_names
  name                  = "${var.system_name}-${var.env_type}-lambda-${each.key}-iam-role"
  description           = "Lambda execution IAM role for ${each.key}"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaServiceToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-lambda-${each.key}-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "functions" {
  for_each  = aws_iam_role.functions
  role_name = each.value.id
  policy_arns = concat(
    [
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
      "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
    ],
    var.lambda_iam_role_policy_arns
  )
}

resource "aws_iam_role_policy" "logs" {
  for_each = aws_iam_role.functions
  name     = "${var.system_name}-${var.env_type}-lambda-${each.key}-logs-iam-policy"
  role     = each.value.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid      = "AllowDescribeLogGroups"
          Effect   = "Allow"
          Action   = ["logs:DescribeLogGroups"]
          Resource = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
        },
        {
          Sid    = "AllowLogStreamAccess"
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ]
          Resource = ["${aws_cloudwatch_log_group.functions[each.key].arn}:*"]
        }
      ],
      (
        var.kms_key_arn != null ? [
          {
            Sid      = "AllowKMSGenerateDataKey"
            Effect   = "Allow"
            Action   = ["kms:GenerateDataKey"]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
}
