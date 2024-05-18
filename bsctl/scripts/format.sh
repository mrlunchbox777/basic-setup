#! /usr/bin/env bash

# Exit on error
set -e

# Get old directory
OLD_DIR="$(pwd)"
ERROR=0

{
	# Get current directory
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

	# Get root directory
	ROOT_DIR="$(dirname "$DIR")"

	# Get the package name
	PACKAGE_NAME="$(basename "$ROOT_DIR")"

	# Get package directory
	PACKAGE_DIR="$ROOT_DIR"
	mkdir -p "$PACKAGE_DIR/bin"
	cd "$PACKAGE_DIR"

	# Build
	echo "Formatting in $PACKAGE_DIR..."
	go fmt -x "$PACKAGE_DIR/..."
} || {
	ERROR=$?
}

cd "$OLD_DIR"
exit $ERROR
