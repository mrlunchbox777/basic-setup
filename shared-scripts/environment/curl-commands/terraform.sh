#! /usr/bin/env bash

# NOTE: don't run environment-validation here, it could cause a loop

#
# global defaults
#
FORCE=false
GET_ALL_VERSIONS=false
GET_INSTALLED_VERSION=false
GET_LATEST_VERSION=false
HELP_INSTALL_PAGE="https://developer.hashicorp.com/terraform/downloads"
INCLUDE_PRERELEASE_VERSIONS=false
SHOW_HELP=false
TARGET_VERSION=""
TEST_VERSION=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
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
		-a|--all-versions    - (flag, current: $GET_ALL_VERSIONS) Print the currently available versions of $COMMAND_NAME and exit.
		-f|--force           - (flag, current: $FORCE) Run the -i commands instead of printing them.
		-h|--help            - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--install-version - (optional, current: "${TARGET_VERSION:-"latest"}") Print commands to install (-f to actually install) the given version of $COMMAND_NAME (pass latest for the -l version) and exit.
		-l|--latest-version  - (flag, current: $GET_LATEST_VERSION) Print the latest available version of $COMMAND_NAME and exit.
		-p|--prerelease      - (flag, current: $INCLUDE_PRERELEASE_VERSIONS) Include prerelease versions as available versions of $COMMAND_NAME for the other commands.
		-r|--read-version    - (flag, current: $GET_INSTALLED_VERSION) Print the currently installed version of $COMMAND_NAME (or empty string) and exit.
		-t|--test-version    - (flag, current: $TEST_VERSION) error if -l does not equal -r and exit.
		-v|--verbose         - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
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
	if [ "$(general-command-installed -c terraform)" == false ]; then
		echo ""
	else
		echo "$(terraform version | head -n 1 | awk '{print $2}' | sed 's/v//g')"
	fi
}

# STANDARD OUTPUT, CUSTOM LOGIC: get all versions (newest first, one per line)
function get_all_versions {
	if [ "$INCLUDE_PRERELEASE_VERSIONS" == true ]; then
		local all_versions="$(git-github-repo-versions -g "https://github.com/hashicorp/terraform" -p v -t)"
	else
		local all_versions="$(git-github-repo-versions -g "https://github.com/hashicorp/terraform" -p v -s -t)"
	fi
	if [ -z "$all_versions" ]; then
		echo "$COMMAND_NAME git-github-repo-versions failed" 1>&2
		exit 1
	fi
	echo "$all_versions" | sed 's/^v//g'
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
	local os_type="$(environment-os-type)"
	local arch_type="$(environment-arch-type)"
	local command_to_run=""
	local os_string=""
	# TODO: support checkums
	(($VERBOSITY > 1)) && echo "attempting install for $os_type $arch_type"
	if [ "$TARGET_VERSION" == "latest" ]; then
		TARGET_VERSION="$(get_latest_version)"
	fi
	local arch_string=""
	if [ "$arch_type" == "x64" ]; then
		local arch_string="amd64"
	elif [ "$arch_type" == "arm64" ]; then
		local arch_string="arm64"
	else
		echo "unsupported arch type - $arch_type" 1>&2
		exit 1
	fi
	if [ "$os_type" == "Linux" ]; then
		local os_string="linux"
	elif [ "$os_type" == "Mac" ]; then
		# TODO: NEEDS TESTING
		local os_string="darwin"
	else
		echo "unsupported os type - $os_type" 1>&2
		exit 1
	fi
	local filename="terraform"
	local archive_name="${filename}_${TARGET_VERSION}_${os_string}_${arch_string}.zip"
	local command_to_run="$(
		cat <<- EOF
			curl -L -s "https://releases.hashicorp.com/terraform/${TARGET_VERSION}/${archive_name}" -o "$archive_name"
			unzip "$archive_name" >/dev/null
			chmod +x "./${filename}"
			sudo mv ./${filename} /usr/local/bin/terraform
			sudo chown root: /usr/local/bin/terraform
			rm -rf "$archive_name"
		EOF
	)"
	if [ "$FORCE" == true ]; then
		bash -c "$command_to_run"
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
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
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
