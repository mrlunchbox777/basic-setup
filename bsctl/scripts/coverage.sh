#! /usr/bin/env bash

# Exit on error
set -e

# Get old directory
OLD_DIR="$(pwd)"
ERROR=0

{
	# Get current directory
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	# Get package directory
	PACKAGE_DIR="$(dirname "$DIR")"
	cd "$PACKAGE_DIR"

	# Run tests
	echo "Running tests in $PACKAGE_DIR..."
	go test -v -coverprofile=test.out -cover ./...
	go tool cover -html=test.out
} || {
	ERROR=$?
}

cd "$OLD_DIR"
exit $ERROR

