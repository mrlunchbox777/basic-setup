#!/usr/bin/env bash

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
if [[ "$pr_title" =~ "bump" ]]; then
    # Clean up the title to make it more CHANGELOG-friendly
    changelog_entry=$(echo "$pr_title" | sed 's/^[^:]*: //' | sed 's/^deps: //' | sed 's/ in .*//')
else
    changelog_entry="Updated dependencies"
fi

echo "Adding CHANGELOG entry for version $new_version"
echo "Entry: $changelog_entry"

# Create the new changelog entry
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
head -n "$separator_line" "$CHANGELOG_FILE" > "$temp_file"
echo "$new_entry" >> "$temp_file"
tail -n +$((separator_line + 1)) "$CHANGELOG_FILE" >> "$temp_file"
mv "$temp_file" "$CHANGELOG_FILE"

echo "CHANGELOG updated successfully"
