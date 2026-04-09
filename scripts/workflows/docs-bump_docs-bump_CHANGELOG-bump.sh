#! /usr/bin/env bash

line_regex="## \\[[0-9]*\\.[0-9]*\\.[0-9]*\\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"
if [ "${GITHUB_REF_NAME:-}" == "main" ] || [ "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)" == "main" ]; then
	echo "On main branch; skipping CHANGELOG comparison."
	exit 0
fi

branchLatestLog=$(cat CHANGELOG.md | sed -n '/---/,$p' | sed '/---/d' | grep -m1 "$line_regex")
mainLatestLog=$(curl -L https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/CHANGELOG.md 2>/dev/null | sed -n '/---/,$p' | sed '/---/d' | grep -m1 "$line_regex")
versionFile="./resources/version.yaml"
legacyVersionFile="./bsctl/static/resources/constants.yaml"

if [ -f "$versionFile" ]; then
	constantVersion=$(yq .BasicSetupCliVersion "$versionFile" | tr -d '"')
else
	constantVersion=$(yq .BasicSetupCliVersion "$legacyVersionFile" | tr -d '"')
fi

if [ -z "$mainLatestLog" ]; then
	echo "Failed to get latest log from github"
	exit 1
fi

if [ -z "$branchLatestLog" ]; then
	echo "Failed to get log from branch"
	exit 1
fi

if [ "$branchLatestLog" == "$mainLatestLog" ]; then
	echo "Branch log not updated"
	exit 1
fi

logVersion=$(echo $branchLatestLog | sed 's/## \[\(.*\)\].*/\1/')
if [ "$logVersion" != "$constantVersion" ]; then
	echo "CHANGELOG version does not match constant version"
	exit 1
fi

branchDate=$(echo "$branchLatestLog" | sed -n 's/.* - \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)/\1/p')
if [ -z "$branchDate" ]; then
	echo "Failed to parse changelog date"
	exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
	echo "python3 is required for changelog date validation"
	exit 1
fi

# Accept changelog dates within +/- 1 day of current UTC date to account for timezone differences.
if ! python3 - "$branchDate" <<'PY'; then
from datetime import datetime, timezone
import sys

branch_date = sys.argv[1]
try:
    parsed_branch_date = datetime.strptime(branch_date, "%Y-%m-%d").date()
except ValueError:
    sys.exit(1)

current_utc_date = datetime.now(timezone.utc).date()
sys.exit(0 if abs((current_utc_date - parsed_branch_date).days) <= 1 else 1)
PY
	echo "CHANGELOG date does not match current date"
	exit 1
fi
