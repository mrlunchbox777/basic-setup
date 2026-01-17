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

# Trim any leading/trailing whitespace
sanitized_version=$(echo "$current_version" | xargs)

# Validate that the version is in the expected SemVer format: MAJOR.MINOR.PATCH (numeric)
if ! [[ "$sanitized_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version '$current_version' from $CONSTANTS_FILE is not in MAJOR.MINOR.PATCH format"
    exit 1
fi

echo "Current version: $sanitized_version"

# Parse version components
IFS='.' read -r major minor patch <<< "$sanitized_version"

# Validate version components are numeric
if [ -z "$major" ] || [ -z "$minor" ] || [ -z "$patch" ]; then
    echo "Error: Invalid version format '$sanitized_version' (expected MAJOR.MINOR.PATCH)"
    exit 1
fi

if ! [[ "$major" =~ ^[0-9]+$ ]] || ! [[ "$minor" =~ ^[0-9]+$ ]] || ! [[ "$patch" =~ ^[0-9]+$ ]]; then
    echo "Error: Version components must be numeric, got '$sanitized_version'"
    exit 1
fi

# Bump patch version
new_patch=$((patch + 1))
new_version="${major}.${minor}.${new_patch}"

echo "New version: $new_version"

# Update the version in the file
yq -i ".BasicSetupCliVersion = \"$new_version\"" "$CONSTANTS_FILE"

echo "Version updated successfully to $new_version"
