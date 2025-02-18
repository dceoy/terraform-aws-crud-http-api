resource "aws_api_gateway_account" "apigateway" {
  cloudwatch_role_arn = aws_iam_role.apigateway.arn
}

resource "aws_iam_role" "apigateway" {
  name                  = "${var.system_name}-${var.env_type}-apigateway-account-iam-role"
  description           = "IAM role for API Gateway account"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAPIGatewayAccountToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-apigateway-account-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "logs" {
  role_name   = aws_iam_role.apigateway.name
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
}

resource "aws_iam_role_policy" "kms" {
  count = var.kms_key_arn != null ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-apigateway-account-kms-iam-policy"
  role  = aws_iam_role.apigateway.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowKMSAccess"
        Effect   = "Allow"
        Action   = ["kms:GenerateDataKey"]
        Resource = [var.kms_key_arn]
      }
    ]
  })
}
