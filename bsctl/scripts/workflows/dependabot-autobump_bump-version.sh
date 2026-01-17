#! /usr/bin/env bash

# This script bumps the patch version in constants.yaml for Dependabot PRs

set -e

CONSTANTS_FILE="./bsctl/static/resources/constants.yaml"

if [ ! -f "$CONSTANTS_FILE" ]; then
    echo "Error: Constants file not found at $CONSTANTS_FILE"
    exit 1
fi

# Get the current version
current_version=$(yq .BasicSetupCliVersion "$CONSTANTS_FILE")

if [ -z "$current_version" ]; then
    echo "Error: Failed to get current version from $CONSTANTS_FILE"
    exit 1
fi

echo "Current version: $current_version"

# Parse version components
major=$(echo "$current_version" | cut -d. -f1)
minor=$(echo "$current_version" | cut -d. -f2)
patch=$(echo "$current_version" | cut -d. -f3)

# Bump patch version
new_patch=$((patch + 1))
new_version="${major}.${minor}.${new_patch}"

echo "New version: $new_version"

# Update the version in the file
yq -i ".BasicSetupCliVersion = \"$new_version\"" "$CONSTANTS_FILE"

echo "Version updated successfully to $new_version"
