#! /usr/env/bin bash

line_regex="## \\[[0-9]*\\.[0-9]*\\.[0-9]*\\] - [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"
branchLatestLog=$(cat CHANGELOG.md | sed -n '/---/,$p' | sed '/---/d' | head -n 1 | grep "$line_regex")
mainLatestLog=$(curl -L https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/CHANGELOG.md 2>/dev/null | sed -n '/---/,$p' | sed '/---/d' | head -n 1 | grep "$line_regex")
constantVersion=$(yq .BasicSetupCliVersion ./bsctl/static/resources/constants.yaml)

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

currentDay=$(date +%d)
branchDay=$(echo $branchLatestLog | sed 's/.* - \([0-9]*\)-\([0-9]*\)-\([0-9]*\)/\3/')
if [ "$currentDay" == "" ]; then
    echo "Failed to get current day"
    exit 1
fi

# Check if the date is the same as the current day or the day before or after (to account for timezones)
if [ "$currentDay" != "$branchDay" ] && [ "$(($currentDay-1))" != "$branchDay" ] && [ "$(($currentDay+1))" != "$branchDay" ]; then
    echo "CHANGELOG date does not match current date"
    exit 1
fi

currentYearAndMonth=$(date +%Y-%m)
branchYearAndMonth=$(echo $branchLatestLog | sed 's/.* - \([0-9]*\)-\([0-9]*\)-\([0-9]*\)/\1-\2/')
if [ "$currentYearAndMonth" != "$branchYearAndMonth" ]; then
    echo "CHANGELOG year and month does not match current year and month"
    exit 1
fi
