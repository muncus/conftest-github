# Rego policy to validate github repo configuration.
# based on go/cloud-dpe-oss-standards

package github.repo

deny_merge_commit[msg]{
  input.allow_merge_commit = true
  msg := "Merge commits should be disabled"
}

warn_default_branch[msg]{
  input.default_branch != "main"
  msg := sprintf("Default branch '%s' found. Consider moving to 'main'", input.default_branch)
}

# License checks.
# TODO: round this out with other license keys.
valid_license_keys := ["apache-2.0"]
deny_supported_license[msg]{
  not has_valid_license
  msg := sprintf("Unsupported license found '%s', should be one of: %s", [ object.get(input, "license.key", "none"), valid_license_keys])
}
has_valid_license {
  input.license.key == valid_license_keys[_]
}

# Un-enforced warnings.

# delete on merge.
warn_delete_merged_branches[msg]{
  input.delete_branch_on_merge != true
  msg := "Consider enabling 'delete branch on merge' in your repo settings"
}

warn_update_branch_button[msg]{
  input.allow_update_branch == false
  msg := "Consider enabling the 'suggest updating pull request branches' option in repo settings."
}
