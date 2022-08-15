# Conftest plugin for Github

This is a plugin for [conftest](conftest.dev) that allows checking of policies
against the settings of Github Repositories.

### Installation and Usage

To Install:

  `conftest plugin install http://github.com/muncus/conftest-github`

To check a repository with the provided policies:

  `conftest github repo $MY_ORG/$MY_REPO test --all-namespaces`

## Repo input document

When fetching relevant information about repositories, it became necessary to
construct an input document format that is more than the objects the github api
presents. The list below contains top-level keys in the input document, and
discusses their contents:

* `input.repo` : Contains the [repository object](https://docs.github.com/en/rest/repos/repos#get-a-repository) as returned by the Github API.
* `input.default_branch_protection` : contains the [branch protection
  rules](https://docs.github.com/en/rest/branches/branch-protection#get-branch-protection)
  for the default branch.
* `input.code_owners`: is the contents of the `.github/CODEOWNERS` file, if
  present.

The `policy` directory contains some examples of checks that might provide
further inspiration.
