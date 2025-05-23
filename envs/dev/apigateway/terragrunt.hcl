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

dependency "lambda" {
  config_path = "../lambda"
  mock_outputs = {
    lambda_function_qualified_arns = {
      dynamodb-handler = "arn:aws:lambda:us-east-1:123456789012:function:dynamodb-handler:1"
    }
    lambda_function_invoke_arns = {
      dynamodb-handler = "arn:aws:lambda:us-east-1:123456789012:function:dynamodb-handler:1"
    }
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn                   = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  lambda_function_qualified_arn = dependency.lambda.outputs.lambda_function_qualified_arns["dynamodb-handler"]
  lambda_function_invoke_arn    = dependency.lambda.outputs.lambda_function_invoke_arns["dynamodb-handler"]
}

terraform {
  source = "${get_repo_root()}/modules/apigateway"
}
