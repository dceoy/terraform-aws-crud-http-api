include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "ecr" {
  config_path = "../ecr"
  mock_outputs = {
    ecr_repository_urls = {
      dynamodb-handler = "123456789012.dkr.ecr.us-east-1.amazonaws.com/dynamodb-handler"
    }
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  ecr_repository_urls = dependency.ecr.outputs.ecr_repository_urls
}

terraform {
  source = "${get_repo_root()}/modules/docker"
}
