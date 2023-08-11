#! /usr/bin/env bash

#
# global defaults
#
FORCE=false
GET_ALL_VERSIONS=false
GET_INSTALLED_VERSION=false
GET_LATEST_VERSION=false
INCLUDE_PRERELEASE_VERSIONS=false
SHOW_HELP=false
TARGET_VERSION=""
TEST_VERSION=false
VERBOSITY=0
HELP_INSTALL_PAGE="https://k3d.io/v5.5.1/#installation"

#
# computed values (often can't be alphabetical)
#
COMMAND_FOR_HELP="$(basename "$0")"
COMMAND_NAME="$(echo "$COMMAND_FOR_HELP" | sed 's/.sh//g')"
LATEST_VERSION_OVERRIDE="${BASIC_SETUP_AWS_CLI_LATEST_VERSION_OVERRIDE}"

#
# helper functions
#

# script help message
function help {
	command_for_help="$COMMAND_FOR_HELP"
	command_name="$COMMAND_NAME"
	cat <<- EOF
		----------
		usage: $COMMAND_FOR_HELP <arguments>
		----------
		description: This script will error, but can install $COMMAND_NAME using curl.
		----------
		-a|--all-versions    - (flag, default: false) Print the currently available versions of $COMMAND_NAME and exit.
		-f|--force           - (flag, default: false) Run the -i commands instead of printing them.
		-h|--help            - (flag, default: false) Print this help message and exit.
		-i|--install-version - (optional, default: "latest") Print commands to install (-f to actually install) the given version of $COMMAND_NAME (pass latest for the -l version) and exit.
		-l|--latest-version  - (flag, default: false) Print the latest available version of $COMMAND_NAME and exit.
		-p|--prerelease      - (flag, default: false) Include prerelease versions as available versions of $COMMAND_NAME for the other commands.
		-r|--read-version    - (flag, default: false) Print the currently installed version of $COMMAND_NAME (or empty string) and exit.
		-t|--test-version    - (flag, default: false) error if -l does not equal -r and exit.
		-v|--verbose         - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: this script errors out by default, you need to pass a flag.
		note: install page - $HELP_INSTALL_PAGE
		----------
		examples:
		get installed version   - $COMMAND_FOR_HELP -r
		test for latest version - $COMMAND_FOR_HELP -t
		install latest version  - $COMMAND_FOR_HELP -f -i
		----------
	EOF
}

# STANDARD OUTPUT, CUSTOM LOGIC: get the installed version (version only, as get_all_versions)
function get_installed_version {
	if [ "$(general-command-installed k3d)" == false ]; then
		echo ""
	else
		k3d --version | grep k3d | awk '{print $3}'
	fi
}

# STANDARD OUTPUT, CUSTOM LOGIC: get all versions (newest first, one per line)
function get_all_versions {
	# TODO: pagination (see go.sh)
	local all_versions="$(curl -s https://api.github.com/repos/k3d-io/k3d/releases | jq -r '.[] | ."tag_name"')"
	if [ "$INCLUDE_PRERELEASE_VERSIONS" == false ]; then
		local all_versions="$(echo "$all_versions" | grep -v \-)"
	fi
	echo "$all_versions"
}

# STANDARD FUNCTION: get the latest version or override
function get_latest_version {
	local all_versions="$(get_all_versions)"
	if [ ! -z "$LATEST_VERSION_OVERRIDE" ]; then
		if (( $(echo "$all_versions" | grep -q $LATEST_VERSION_OVERRIDE >/dev/null 2>&1; echo $? ) != 0 )); then
			echo "$COMMAND_NAME LATEST_VERSION_OVERRIDE not found - $LATEST_VERSION_OVERRIDE" 1>&2
			exit 1
		else
			echo "$LATEST_VERSION_OVERRIDE"
		fi
	else
		echo "$all_versions" | head -n 1
	fi
}

# CUSTOM FUNCTION: extra test version functionality
function custom_test_version {
	return 0
}

# STANDARD FUNCTION: test the installed version
function test_version {
	local installed_version="$(get_installed_version)"
	if [ -z "$installed_version" ]; then
		echo "$COMMAND_NAME not installed" 1>&2
		exit 1
	fi
	custom_test_version
	local latest_version="$(get_latest_version)"
	if [ "$installed_version" != "$latest_version" ]; then
		echo "newer $COMMAND_NAME version available" 1>&2
		exit 1
	fi
}

# CUSTOM FUNCTION: install the target version
function install_version {
	if [ "$TARGET_VERSION" == "latest" ]; then
		TARGET_VERSION="$(get_latest_version)"
	fi
	local command_to_run="curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=$TARGET_VERSION bash"
	if [ "$FORCE" == true ]; then
		eval "$command_to_run"
	else
		echo "$command_to_run"
	fi
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# The version to install, optional argument
	-i | --install-version)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			TARGET_VERSION="$2"
			shift 2
		else
			TARGET_VERSION="latest"
			shift 1
		fi
		;;
	# Get all versions flag
	-a | --all-versions)
		GET_ALL_VERSIONS=true
		shift
		;;
	# Force flag
	-f | --force)
		FORCE=true
		shift
		;;
	# Get latest version flag
	-l | --latest-version)
		GET_LATEST_VERSION=true
		shift
		;;
	# Include prerelease versions flag
	-p | --prerelease)
		INCLUDE_PRERELEASE_VERSIONS=true
		shift
		;;
	# Read installed version flag
	-r | --read-version)
		GET_INSTALLED_VERSION=true
		shift
		;;
	# Test version flag
	-t | --test-version)
		TEST_VERSION=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# verbosity multi-flag
	-v | --verbose)
		((VERBOSITY+=1))
		shift
		;;
	# unsupported flags and arguments
	-* | --*=)
		echo "Error: Unsupported flag $1" >&2
		help
		exit 1
		;;
	# preserve positional arguments
	*)
		PARAMS="$PARAMS $1"
		shift
		;;
	esac
done

#
# Do the work
#
[ $SHOW_HELP == true ] && help && exit 0
[ $GET_INSTALLED_VERSION == true ] && get_installed_version && exit 0
[ $TEST_VERSION == true ] && test_version && exit 0
[ $GET_LATEST_VERSION == true ] && get_latest_version && exit 0
[ $GET_ALL_VERSIONS == true ] && get_all_versions && exit 0
[ ! -z "$TARGET_VERSION" ] && install_version && exit 0

help
exit 1