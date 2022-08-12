#!/usr/bin/env bash

# github-conftest retrieves repository configuration from github using the cli.
# This allows organizations to write policy about the way their repos should be
# configured.

# Check if a specified command exists on the path and is executable
function check_command () {
    if ! [[ -x $(command -v $1) ]] ; then
        echo "$1 not installed"
        exit 1
    fi
}

function usage () {
    echo "Conftest plugin to allow policy checks on github objects."
    echo "Currently supports Repositories."
}

CONFTEST_BIN="conftest"

# Check the required commands are available on the PATH
check_command "gh"


if [[ ($# -eq 0) || ($1 == "--help") || ($1 == "-h") ]]; then
    # No commands or the --help flag passed and we'll show the usage instructions
    usage
fi

subcommand=$1
shift;
if [[ "${subcommand}" == "repo" ]] ; then
    # Grab the repo object, and feed it back to conftest.
    repo_json=$(gh api repos/${1})
    default_branch=$(echo "$repo_json" | jq -r '.default_branch')
    branch_protection_json=$(gh api repos/${1}/branches/${default_branch}/protection)
    # If this command fails, use an empty object, instead of the error provided.
    if [ "${?}" != "0" ]; then
      branch_protection_json="{}"
    fi
    # TODO: consider parsing this into a sub-object for easier checking.
    owners=$(curl --silent -L https://raw.githubusercontent.com/${1}/${default_branch}/.github/CODEOWNERS)
    metadoc=$(cat <<-EOD
    { "repo": ${repo_json},
      "default_branch_protection": ${branch_protection_json},
      "code_owners": "${owners}" }
EOD
)

    # echo $metadoc
    echo $metadoc | ${CONFTEST_BIN} ${@:2} -

elif [[ "${subcommand}" == "pr" ]]; then
    # PR takes "org/repo N" syntax.
    pr_json=$(gh api repos/${1}/pulls/${2})
    shift; shift; # eat the params we used above.
    echo $pr_json | ${CONFTEST_BIN} test -n github.${subcommand} ${@} -
else
  echo "Invalid arguments"
  usage
fi
