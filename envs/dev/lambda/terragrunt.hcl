include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "docker" {
  config_path = "../docker"
  mock_outputs = {
    docker_registry_primary_image_uris = {
      dynamodb-handler = "123456789012.dkr.ecr.us-east-1.amazonaws.com/dynamodb-handler:latest"
    }
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "dynamodb" {
  config_path = "../dynamodb"
  mock_outputs = {
    dynamodb_table_id                       = "dynamodb-table-id"
    dynamodb_table_operation_iam_policy_arn = "arn:aws:iam::123456789012:policy/dynamodb-table-operation-iam-policy"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn       = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  lambda_image_uris = dependency.docker.outputs.docker_registry_primary_image_uris
  lambda_environment_variables = {
    for k in keys(dependency.docker.outputs.docker_registry_primary_image_uris) : k => {
      DYNAMODB_TABLE_NAME = dependency.dynamodb.outputs.dynamodb_table_id
      SYSTEM_NAME         = include.root.inputs.system_name
      ENV_TYPE            = include.root.inputs.env_type
    }
  }
  lambda_iam_role_policy_arns = [dependency.dynamodb.outputs.dynamodb_table_operation_iam_policy_arn]
}

terraform {
  source = "${get_repo_root()}/modules/lambda"
}
