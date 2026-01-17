#! /usr/bin/env bash

# This script updates CHANGELOG.md for Dependabot PRs

set -e

CHANGELOG_FILE="./CHANGELOG.md"
CONSTANTS_FILE="./bsctl/static/resources/constants.yaml"

if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "Error: CHANGELOG file not found at $CHANGELOG_FILE"
    exit 1
fi

if [ ! -f "$CONSTANTS_FILE" ]; then
    echo "Error: Constants file not found at $CONSTANTS_FILE"
    exit 1
fi

# Get the new version from constants.yaml
new_version=$(yq .BasicSetupCliVersion "$CONSTANTS_FILE")

if [ -z "$new_version" ]; then
    echo "Error: Failed to get version from $CONSTANTS_FILE"
    exit 1
fi

# Get current date in YYYY-MM-DD format
current_date=$(date +%Y-%m-%d)

# Get PR title from environment variable (set by GitHub Actions)
pr_title="${PR_TITLE:-Dependency updates}"

# Extract dependency information from PR title if it's a Dependabot PR
if [[ "$pr_title" =~ [Bb]ump[[:space:]]+([^[:space:]]+)[[:space:]]+from[[:space:]]+([^[:space:]]+)[[:space:]]+to[[:space:]]+([^[:space:]]+) ]]; then
    # Pattern: "Bump <dependency> from <old_version> to <new_version> ..."
    dep_name="${BASH_REMATCH[1]}"
    old_version="${BASH_REMATCH[2]}"
    new_dep_version="${BASH_REMATCH[3]}"
    changelog_entry="Bump ${dep_name} from ${old_version} to ${new_dep_version}"
elif [[ "$pr_title" =~ [Uu]pdate[[:space:]]+([^[:space:]]+)[[:space:]]+to[[:space:]]+([^[:space:]]+) ]]; then
    # Pattern: "Update <dependency> to <new_version> ..."
    dep_name="${BASH_REMATCH[1]}"
    new_dep_version="${BASH_REMATCH[2]}"
    changelog_entry="Update ${dep_name} to ${new_dep_version}"
elif [[ "$pr_title" =~ ^(chore\(deps\)|build\(deps\)|chore:|build:).*[Bb]ump ]]; then
    # Fallback for other "bump" titles with proper prefix matching
    cleaned_title="$pr_title"
    # Remove leading "<scope>: " if present (e.g., "chore(deps): ")
    if [[ "$cleaned_title" == *": "* ]]; then
        cleaned_title="${cleaned_title#*: }"
    fi
    # Remove leading "deps: " if present
    if [[ "$cleaned_title" == deps:\ * ]]; then
        cleaned_title="${cleaned_title#deps: }"
    fi
    # Remove directory suffix starting with " in " (e.g., " in /backend")
    if [[ "$cleaned_title" == *" in "* ]]; then
        cleaned_title="${cleaned_title%% in *}"
    fi
    changelog_entry="$cleaned_title"
else
    changelog_entry="Updated dependencies"
fi

echo "Adding CHANGELOG entry for version $new_version"
echo "Entry: $changelog_entry"

# Create the new changelog entry with proper variable expansion
# Add one blank line at the end for separator between versions
new_entry="## [$new_version] - $current_date
### Changed
- $changelog_entry
"

# Find the line number where "---" appears (the separator after the header)
separator_line=$(grep -n "^---$" "$CHANGELOG_FILE" | head -1 | cut -d: -f1)

if [ -z "$separator_line" ]; then
    echo "Error: Could not find separator '---' in CHANGELOG"
    exit 1
fi

# Insert the new entry after the separator line
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT ERR  # Clean up temp file on exit or error
head -n "$separator_line" "$CHANGELOG_FILE" > "$temp_file"
echo "$new_entry" >> "$temp_file"
tail -n +$((separator_line + 1)) "$CHANGELOG_FILE" >> "$temp_file"

# Atomic move to avoid corruption
if mv "$temp_file" "$CHANGELOG_FILE"; then
    echo "CHANGELOG updated successfully"
else
    echo "Error: Failed to update CHANGELOG"
    exit 1
fi
