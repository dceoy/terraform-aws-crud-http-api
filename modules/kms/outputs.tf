output "kms_key_arn" {
  description = "KMS key ARN"
  value       = length(aws_kms_key.custom) > 0 ? aws_kms_key.custom[0].arn : null
}

output "kms_key_alias_name" {
  description = "KMS key alias name"
  value       = length(aws_kms_alias.custom) > 0 ? aws_kms_alias.custom[0].name : null
}
