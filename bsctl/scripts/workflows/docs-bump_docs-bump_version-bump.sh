#! /usr/bin/env bash

branchVersion=$(yq .BasicSetupCliVersion ./bsctl/static/resources/constants.yaml)
mainVersion=$(curl -L https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/bsctl/static/resources/constants.yaml 2>/dev/null | yq .BasicSetupCliVersion)

if [ -z "$mainVersion" ]; then
    echo "Failed to get latest version from github"
    exit 1
fi

if [ -z "$branchVersion" ]; then
    echo "Failed to get version from branch"
    exit 1
fi

if [ "$branchVersion" == "$mainVersion" ]; then
    echo "Branch version not updated"
    exit 1
fi
