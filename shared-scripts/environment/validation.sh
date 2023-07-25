#! /usr/bin/env bash

set_e_after=0
if [[ $- =~ e ]]; then
	set_e_after=1
else
	set -e
fi

update_e() {
	if (( set_e_after == 0 )); then
		set +e
	fi
}

#
# global defaults
#
ALLOW_CURL_INSTALLS=false
BASIC_SETUP_DATA_DIRECTORY="$HOME/.basic-setup/"
ERROR_MESSAGES=()
LABELS=("all")
LABELS_FILTER_MODE="replace" # union, intersection, replace
FORCE=false
# OVERRIDE_FILE_PATH="" # how to support this, merge might be rough
PREVIOUSLY_VALIDATED_FILE_NAME=".environment_validated_by_environment-validation"
VERBOSITY=0

#
# computed values (often can't be alphabetical)
#
PACKAGES="$(cat "$(general-get-basic-setup-dir)/install/index.json")"

#
# helper functions
#

# script help message
function help {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: This script will validate that everything that is needed is included in your environment.
		----------
		-f|--force   - (flag, default: false) Force the validation (don't skip if previously passed).
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: This script will error out if the environment is misconfigured. It should also tell you what can be done to correct the issue.
		----------
		examples:
		validate environment - $command_for_help
		----------
	EOF
}

function is_command_installed {
	local command_name=$1
	(("$(command -v "$command_name" 2>&1 > /dev/null; echo $?)" == 0)) && echo true || echo false
}

function get_package_manager_name {
	# TODO: this may need to be done per package (for things like aws cli where it's on apt but not enabled)
	local package_manager_name="unknown"
	[ "$(is_command_installed apt-get)" == true ] && local package_manager_name="apt-get"
	[ "$(is_command_installed brew)" == true ] && local package_manager_name="brew"
	[ "$(is_command_installed pacman)" == true ] && local package_manager_name="pacman"
	[ "$(is_command_installed yum)" == true ] && local package_manager_name="yum"
	[ "$(is_command_installed winget)" == true ] && local package_manager_name="winget"
	[ "$(is_command_installed curl)" == true ] && local package_manager_name="curl"

	if [ "$package_manager_name" == "unknown" ] || { [ "$package_manager_name" == "curl" ] && [ "$ALLOW_CURL_INSTALLS" != true ]; }; then
		# TODO: this may not be exit worthy
		echo "no valid package manager found and/or curl installs not allowed" 1>&2
		exit 1
	fi
	echo "$package_manager_name"
}

function check_for_jq {
	local is_jq_installed=$(is_command_installed "jq")
	if (( $is_jq_installed == 0 )); then
		# TODO maybe install it instead
		echo "\`jq\` must be installed to get a list of to be installed packages. Please follow these instructions - https://stedolan.github.io/jq/download/"
		usage
		exit 1
	fi
}

function check_for_skip {
	# Include important flags in the file name
	PREVIOUSLY_VALIDATED_FILE_NAME="${PREVIOUSLY_VALIDATED_FILE_NAME}_$(echo "${LABELS[@]}" | sed 's/ /_/g')_${LABELS_FILTER_MODE}_${ALLOW_CURL_INSTALLS}"
	mkdir -p $BASIC_SETUP_DATA_DIRECTORY
	if (( "$FORCE" == 0 )) && [ "$(find "$BASIC_SETUP_DATA_DIRECTORY" -maxdepth 1 -name $PREVIOUSLY_VALIDATED_FILE_NAME -mmin -1440)" ]; then
	# TODO: add verbose and push this out
	# echo "previously validated - skipping" 1>&2
		update_e
		exit 0
	fi
}

# TODO WIP functions below
function should_be_installed {
	local json_object=$1

	local command_name=$(echo "$json_object" | jq -r '.command')
	local is_command_installed=$(is_command_installed "$command_name")
	if (( $is_command_installed == 0 )); then
		local human_name=$(echo "$json_object" | jq -r '.name')
		local extra=$(echo "$json_object" | jq -r '."install-page"')
		local package_name=$(get_package_name "$json_object")
		local message="unable to find $human_name ($command_name), '$package_manager_name install $package_name' $extra"
		local error_message=$(echo "$json_object" | jq -c --arg m "$message" '{message: $m} + .')
		ERROR_MESSAGES+=("$error_message")
	fi
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
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

check_for_skip
# TODO: add a check for on main at latest

# First and foremost we must have modern bash and jq
if [[ "$BASH_VERSION" =~ ^3.*$ ]]; then
	echo "Bash 3 installed... please install bash (brew install bash)" 1>&2
	echo "if you have already done that ensure you aren't calling with an alias to MacOS bash (which defaults to 3)" 1>&2
	help
	exit 1
fi
check_for_jq
# TODO: merge config override
# Merge file paths - https://stackoverflow.com/a/36218044
# jq -s 'reduce .[] as $item ({}; . * $item)'

# TODO: handle the different ways we want to handle filters
packages_keys=($(echo $PACKAGES | jq '.packages[] | select(.labels[] | . == "'${LABELS[0]}'") | .name'))
for package_key in "${packages_keys[@]}"; do
	temp="$(echo $PACKAGES | jq '.packages[] | select(.name == "'$package_key'")')"
	should_be_installed "$temp"
done
# TODO: WIP below

# fail after running everything to generate a list
if (( "${#ERROR_MESSAGES[@]}" > 0 )); then
	echo "Found Failures: " 1>&2
	for error_message_object in "${ERROR_MESSAGES[@]}"; do
		error_message=$(echo $error_message_object | jq -r '.message')
		echo "  - $error_message" 1>&2
	done
	help
	exit 1
fi

# Extra more manual validations
aws_version=$(aws --version | sed 's/ /\n/g' | head -n 1 | sed 's|/|\n|g' | tail -n 1)
aws_version_major=$(echo "$aws_version" | sed 's/\./\n/g' | head -n 1)
aws_version_minor=$(echo "$aws_version" | sed 's/\./\n/g' | head -n 2 | tail -n 1)
if (( $aws_version_major < 2 )); then
	echo "aws is not version 2, uninstall/purge old version, $package_manager_name install awscli, and/or follow migration instructions here https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html" 1>&2
	help
	exit 1
elif (( $aws_version_minor < 10 )); then
	echo "aws version is < 2.10, uninstall/purge old version, $package_manager_name install awscli" 1>&2
	help
	exit 1
fi

# TODO: find a way to force gnu-sed on OSX - https://gist.github.com/andre3k1/e3a1a7133fded5de5a9ee99c87c6fa0d
if [ "$(environment-os-type --mac)" == "true" ]; then
	if [ "$(brew list --formula | grep coreutils)" != "coreutils" ]; then
		echo "unable to find coreutils. Install with brew install coreutils" 1>&2
		help
		exit 1
	fi
fi

# If everything worked, note it so that future checks can be skipped
touch "${BASIC_SETUP_DATA_DIRECTORY}${PREVIOUSLY_VALIDATED_FILE_NAME}"

update_e
