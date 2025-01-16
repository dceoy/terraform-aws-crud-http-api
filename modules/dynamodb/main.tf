# trivy:ignore:avd-aws-0024
# trivy:ignore:avd-aws-0025
resource "aws_dynamodb_table" "db" {
  name           = local.dynamodb_table_name
  hash_key       = var.dynamodb_table_hash_key
  table_class    = var.dynamodb_table_class
  billing_mode   = var.dynamodb_table_billing_mode
  read_capacity  = var.dynamodb_table_billing_mode == "PROVISIONED" ? var.dynamodb_table_read_capacity : null
  write_capacity = var.dynamodb_table_billing_mode == "PROVISIONED" ? var.dynamodb_table_write_capacity : null
  attribute {
    name = var.dynamodb_table_hash_key
    type = "S"
  }
  point_in_time_recovery {
    enabled = var.dynamodb_table_point_in_time_recovery_enabled
  }
  dynamic "server_side_encryption" {
    for_each = var.kms_key_arn != null ? [true] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }
  tags = {
    Name       = local.dynamodb_table_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
