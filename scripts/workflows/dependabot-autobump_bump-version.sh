#! /usr/bin/env bash

# This script bumps the patch version in the version source for Dependabot PRs

set -eo pipefail

VERSION_FILE="./resources/version.yaml"
LEGACY_CONSTANTS_FILE="./bsctl/static/resources/constants.yaml"

if [ ! -f "$VERSION_FILE" ] && [ ! -f "$LEGACY_CONSTANTS_FILE" ]; then
	echo "Error: Version files not found at $VERSION_FILE or $LEGACY_CONSTANTS_FILE"
	exit 1
fi

# Get the current version
if [ -f "$VERSION_FILE" ]; then
	current_version=$(yq .BasicSetupCliVersion "$VERSION_FILE")
else
	current_version=$(yq .BasicSetupCliVersion "$LEGACY_CONSTANTS_FILE")
fi

if [ -z "$current_version" ]; then
	echo "Error: Failed to get current version from $VERSION_FILE or $LEGACY_CONSTANTS_FILE"
	exit 1
fi

# Trim any leading/trailing whitespace
sanitized_version=$(echo "$current_version" | xargs)

# Validate that the version is in the expected SemVer format: MAJOR.MINOR.PATCH (numeric)
if ! [[ "$sanitized_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Error: Version '$current_version' is not in MAJOR.MINOR.PATCH format"
	exit 1
fi

echo "Current version: $sanitized_version"

# Parse version components
IFS='.' read -r major minor patch <<<"$sanitized_version"

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
if [ -f "$VERSION_FILE" ]; then
	yq -i ".BasicSetupCliVersion = \"$new_version\"" "$VERSION_FILE"
else
	mkdir -p "$(dirname "$VERSION_FILE")"
	printf 'BasicSetupCliVersion: "%s"\n' "$new_version" >"$VERSION_FILE"
fi

if [ -f "$LEGACY_CONSTANTS_FILE" ]; then
	yq -i ".BasicSetupCliVersion = \"$new_version\"" "$LEGACY_CONSTANTS_FILE"
fi

echo "Version updated successfully to $new_version"
