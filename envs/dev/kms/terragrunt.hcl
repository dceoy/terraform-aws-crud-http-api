include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                   = "${get_repo_root()}/modules/kms"
  copy_terraform_lock_file = false
}
