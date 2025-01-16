locals {
  dynamodb_table_name = var.dynamodb_table_name != null ? var.dynamodb_table_name : "${var.system_name}-${var.env_type}-dynamodb-table"
}
