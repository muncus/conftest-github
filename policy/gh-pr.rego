# Rego policy checks for Github PRs
package github.pr

warn_locked[msg]{
  input.locked == true
  msg = "This PR is locked. It will need to be unlocked before changes can be made."
}

# True if this PR is against the repo's base branch.
based_on_default_branch {
  input.base.ref == input.base.repo.default_branch
}

# Denies PRs made against non-default branches on the repo.
deny_branch_check[msg]{
  not based_on_default_branch
  msg = sprintf("PRs should be made against the repo's default branch (%s)", [input.base.repo.default_branch])
}

is_mergeable = [true] {
  input.mergeable == true
}

is_mergeable = [true]{
  input.merged == true
}

# Fail if the PR is not considered mergeable, or already been merged.
deny_not_mergeable[msg] {
  not is_mergeable
  msg = sprintf("PR not mergeable (%s): see %s for details", [input.mergeable, input.html_url])
}

# pretty naive- just checks for any prefix.
# consider building this as a partial result, so orgs can add their own
# restrictions.
is_conventional_commit(s) {
  regex.match(`^[a-z_]+\((.+\))?: .+`, s)
}

deny_unconventional_title[{"msg": msg, "details": details}]{
  not is_conventional_commit(input.title)
  msg = "Please use Conventional Commit style for PR titles."
  details = sprintf("see conventionalcommits.org (found '%s')", [input.title])
}
