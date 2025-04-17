# trivy:ignore:avd-aws-0024
# trivy:ignore:avd-aws-0025
resource "aws_dynamodb_table" "db" {
  name                        = local.dynamodb_table_name
  billing_mode                = var.dynamodb_billing_mode
  hash_key                    = var.dynamodb_hash_key
  range_key                   = var.dynamodb_range_key
  read_capacity               = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_read_capacity : null
  write_capacity              = var.dynamodb_billing_mode == "PROVISIONED" ? var.dynamodb_write_capacity : null
  stream_enabled              = var.dynamodb_stream_enabled
  stream_view_type            = var.dynamodb_stream_view_type
  table_class                 = var.dynamodb_table_class
  deletion_protection_enabled = var.dynamodb_deletion_protection_enabled
  restore_date_time           = var.dynamodb_restore_date_time
  restore_source_name         = var.dynamodb_restore_source_name
  restore_source_table_arn    = var.dynamodb_restore_source_table_arn
  restore_to_latest_time      = var.dynamodb_restore_to_latest_time
  dynamic "attribute" {
    for_each = var.dynamodb_attributes
    content {
      name = attribute.key
      type = attribute.value
    }
  }
  dynamic "ttl" {
    for_each = var.dynamodb_ttl_attribute_name != null ? [true] : []
    content {
      enabled        = true
      attribute_name = var.dynamodb_ttl_attribute_name
    }
  }
  point_in_time_recovery {
    enabled = var.dynamodb_point_in_time_recovery_enabled
  }
  dynamic "local_secondary_index" {
    for_each = var.dynamodb_local_secondary_indexes
    content {
      name               = local_secondary_index.key
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }
  dynamic "global_secondary_index" {
    for_each = var.dynamodb_global_secondary_indexes
    content {
      name               = global_secondary_index.key
      hash_key           = global_secondary_index.value.hash_key
      projection_type    = global_secondary_index.value.projection_type
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      read_capacity      = lookup(global_secondary_index.value, "read_capacity", null)
      write_capacity     = lookup(global_secondary_index.value, "write_capacity", null)
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      dynamic "on_demand_throughput" {
        for_each = lookup(global_secondary_index.value, "on_demand_throughput_max_read_request_units", null) != null || lookup(global_secondary_index.value, "on_demand_throughput_max_write_request_units", null) != null ? [true] : []
        content {
          max_read_request_units  = lookup(global_secondary_index.value, "on_demand_throughput_max_read_request_units", null)
          max_write_request_units = lookup(global_secondary_index.value, "on_demand_throughput_max_write_request_units", null)
        }
      }
    }
  }
  dynamic "replica" {
    for_each = var.dynamodb_replica_regions
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = lookup(replica.value, "kms_key_arn", null)
      propagate_tags         = lookup(replica.value, "propagate_tags", null)
      point_in_time_recovery = lookup(replica.value, "point_in_time_recovery", null)
    }
  }
  dynamic "server_side_encryption" {
    for_each = var.kms_key_arn != null ? [true] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }
  dynamic "import_table" {
    for_each = var.dynamodb_import_table
    content {
      input_format           = import_table.value.input_format
      input_compression_type = lookup(import_table.value, "input_compression_type", null)
      s3_bucket_source {
        bucket       = import_table.value.s3_bucket_source_bucket
        bucket_owner = lookup(import_table.value, "s3_bucket_source_bucket_owner", null)
        key_prefix   = lookup(import_table.value, "s3_bucket_source_key_prefix", null)
      }
      dynamic "input_format_options" {
        for_each = lookup(import_table.value, "input_format_options_csv_delimiter", null) != null || lookup(import_table.value, "input_format_options_csv_header_list", null) != null ? [true] : []
        content {
          csv {
            delimiter   = lookup(import_table.value, "input_format_options_csv_delimiter", null)
            header_list = lookup(import_table.value, "input_format_options_csv_header_list", null)
          }
        }
      }
    }
  }
  dynamic "on_demand_throughput" {
    for_each = var.dynamodb_on_demand_throughput_max_read_request_units != null || var.dynamodb_on_demand_throughput_max_write_request_units != null ? [true] : []
    content {
      max_read_request_units  = var.dynamodb_on_demand_throughput_max_read_request_units
      max_write_request_units = var.dynamodb_on_demand_throughput_max_write_request_units
    }
  }
  tags = {
    Name       = local.dynamodb_table_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    ignore_changes = [global_secondary_index, read_capacity, write_capacity]
  }
}

resource "aws_iam_policy" "db" {
  name        = "${var.system_name}-${var.env_type}-dynamodb-table-operation-iam-policy"
  description = "DynamoDB table operation IAM policy for ${aws_dynamodb_table.db.name}"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      [
        {
          Sid    = "AllowDynamoDBAccess"
          Effect = "Allow"
          Action = [
            "dynamodb:DeleteItem",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:UpdateItem"
          ]
          Resource = [
            aws_dynamodb_table.db.arn,
            "${aws_dynamodb_table.db.arn}/index/*"
          ]
          Condition = {
            StringEquals = {
              "aws:ResourceTag/SystemName" = var.system_name
              "aws:ResourceTag/EnvType"    = var.env_type
            }
          }
        }
      ],
      (
        var.kms_key_arn != null ? [
          {
            Sid    = "AllowKMSAccess"
            Effect = "Allow"
            Action = [
              "kms:Decrypt",
              "kms:Encrypt",
              "kms:GenerateDataKey"
            ]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
}
