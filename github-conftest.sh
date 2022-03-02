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
elif [[ $# -ge 1 ]]; then
    # assume evrything is a repo right now.
    repo_json=$(gh api repos/${1})
    echo $repo_json | ${CONFTEST_BIN} test ${@:2} -

fi
