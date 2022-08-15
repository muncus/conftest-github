# Rego policy to validate github repo configuration.
# based on go/cloud-dpe-oss-standards

package github.repo

warn_default_branch_name[msg] {
  input.repo.default_branch != "main"
  msg := sprintf("Default branch '%s' found. Consider moving to 'main'", input.repo.default_branch)
}

# License checks.
# TODO: round this out with other license keys.
valid_license_keys := ["apache-2.0"]
deny_supported_license[msg]{
  not has_valid_license
  msg := sprintf("Unsupported license found '%s', should be one of: %s", [ object.get(input.repo, "license.key", "none"), valid_license_keys])
}
has_valid_license {
  input.repo.license.key == valid_license_keys[_]
}

warn_squash_merge_disabled[msg] {
  msg := "Squash merges are commonly enabled for our Github Repos. Consider enabling it."
  input.repo.allow_squash_merge != true
}

warn_auto_merge[msg] {
  input.repo.allow_auto_merge != true
  msg := "Consider enabling Auto-merge. It can save time for all contributors!"
}

deny_merge_commit[msg]{
  msg := "Merge commits are commonly disabled. Consider disabling them."
  input.repo.allow_merge_commit != false
}
deny_rebase_merge[msg]{
  msg := "Rebase merges are commonly disabled. Consider disabling them."
  input.repo.allow_rebase_merge != false
}

# delete on merge.
warn_delete_merged_branches[msg]{
  input.repo.delete_branch_on_merge != true
  msg := "Consider enabling 'delete branch on merge' in your repo settings"
}

warn_update_branch_button[msg]{
  input.repo.allow_update_branch == false
  msg := "Consider enabling the 'suggest updating pull request branches' option in repo settings."
}

######
# Branch Protection Rules
######

# Catch the case where we cannot fetch branch protection.
deny_permission [msg]{
  object.get(input, "default_branch_protection.url", "empty") == "empty"
  #input != null
  #msg := sprintf("bloop: %s", [object.get(input, "default_branch_protection.url", "f")])
  msg := "Failed to fetch branch protection data. Branch protection policies were not checked."
}

warn_review_count[msg] {
  input.default_branch_protection.required_approving_review_count < 2
  contains(input.repo.name, "samples")
  msg := "Review count of 2 is recommended for language samples."
}

deny_review_count[msg] {
  input.default_branch_protection.required_approving_review_count < 1
  msg := "Review count should be at least 1."
}

deny_codeowners_required[msg] {
  input.default_branch_protection.require_code_owner_reviews != true
  msg := "Code Owner reviews should be required"
}

warn_linear_history[msg] {
  input.default_branch_protection.required_linear_history.enabled != true
  msg := "Consider requiring Linear History for the default branch."
}

fail_allow_force_pushes[msg] {
  input.default_branch_protection.allow_force_pushes != false
  msg := "Force pushes are allowed on this branch. They should be disabled."
}


#input.default_branch_protection

