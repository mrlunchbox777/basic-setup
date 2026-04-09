#! /usr/bin/env bash

branchName="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")}"
if [ "$branchName" == "main" ]; then
	echo "Running on main branch; skipping version divergence check"
	exit 0
fi

versionFile="./resources/version.yaml"
legacyVersionFile="./bsctl/static/resources/constants.yaml"

if [ -f "$versionFile" ]; then
	branchVersion=$(yq .BasicSetupCliVersion "$versionFile" | tr -d '"')
else
	branchVersion=$(yq .BasicSetupCliVersion "$legacyVersionFile" | tr -d '"')
fi

mainVersion=$(curl -L https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/resources/version.yaml 2>/dev/null | yq .BasicSetupCliVersion | tr -d '"')
if [ -z "$mainVersion" ] || [ "$mainVersion" == "null" ]; then
	mainVersion=$(curl -L https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/bsctl/static/resources/constants.yaml 2>/dev/null | yq .BasicSetupCliVersion | tr -d '"')
fi

if [ -z "$mainVersion" ] || [ "$mainVersion" == "null" ]; then
	echo "Failed to get latest version from github"
	exit 1
fi

if [ -z "$branchVersion" ] || [ "$branchVersion" == "null" ]; then
	echo "Failed to get version from branch"
	exit 1
fi

if [ "$branchVersion" == "$mainVersion" ]; then
	echo "Branch version not updated"
	exit 1
fi
