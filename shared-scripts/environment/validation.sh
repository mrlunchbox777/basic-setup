#! /usr/bin/env bash

#
# Error handling
#
SET_E_AFTER=true
if [[ $- =~ e ]]; then
	SET_E_AFTER=false
else
	set -e
fi

# set e to the right value after running the script
function update_e {
	if [ "$SET_E_AFTER" == "true" ]; then
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
PREVIOUSLY_VALIDATED_FILE_NAME=".environment_validated_by_environment-validation"
SHOW_HELP=false
SUPPORTED_PACKAGE_MANAGERS=("apt-get" "brew" "curl" "pacman" "yum" "winget")
TARGET_BRANCH="main"
VERBOSITY=0

#
# computed values (often can't be alphabetical)
#
PACKAGES="$(cat "$(general-get-basic-setup-dir)/resources/install/index.json")"
# TODO: make this override do something
PACKAGES_OVERRIDE_DIR="$([ ! -z "$BASIC_SETUP_ENVIRONMENT_VALIDATION_INDEX_OVERRIDE_DIRECTORY_PATH"] && [ -d "$BASIC_SETUP_ENVIRONMENT_VALIDATION_INDEX_OVERRIDE_DIRECTORY_PATH" ] && echo "$$BASIC_SETUP_ENVIRONMENT_VALIDATION_INDEX_OVERRIDE_DIRECTORY_PATH" || echo "" )"
TARGET_BRANCH="${BASIC_SETUP_ENVIRONMENT_VALIDATION_TARGET_BRANCH:-$TARGET_BRANCH}"

# TODO: add verbosity to everything

#
# helper functions
#

# TODO add --update-curl-installs
# TODO add install missing
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

# ensure a specific command is installed
function is_command_installed {
	general-command-installed "$1"
}

# select the correct package manager and return it's content for a given package
function get_package_manager_content {
	# TODO: this may need to be done per package (for things like aws cli where it's on apt but not enabled)
	local package_manager_name=""
	local package_content="$1"
	for i in "${SUPPORTED_PACKAGE_MANAGERS[@]}"; do
		# skip the package manager if it's not installed
		if [ "$(is_command_installed "$i")" == false ]; then
			continue
		fi
		# skip the package manager if it's not found or enabled
		local package_manager_content="$(echo "$package_content" | jq '."package-managers"[] | select((."manager-name" == "'"$i"'") and .enabled == true)')"
		if [ -z "$package_manager_content" ]; then
			continue
		fi
		# skip the package manager if it's curl and curl isn't allowed
		if [ "$ALLOW_CURL_INSTALLS" == false ] && [ "$i" == "curl" ]; then
			continue
		fi
		# set the package manager if it's not been set, or it's been set to curl
		if [ -z "$package_manager_name" ] || [ "$package_manager_name" == "curl" ]; then
			package_manager_name="$i"
		fi
	done

	if [ -z "$package_manager_name" ]; then
		echo "no valid package manager found for $(echo "$package_content" | jq '.name')" 1>&2
		# return empty if not found
		echo ""
	else
		echo "$package_content" | jq '."package-managers"[] | select(."manager-name" == "'"$package_manager_name"'")'
	fi
}

# ensure a modern jq version is being used
function check_for_jq {
	local is_jq_installed=$(is_command_installed "jq")
	if [ $is_jq_installed == false ]; then
		# TODO maybe install it instead
		echo "\`jq\` must be installed to get a list of to be installed packages. Please follow these instructions - https://stedolan.github.io/jq/download/"
		help
		update_e
		exit 1
	fi
}

# ensure a modern bash version is being used
function check_for_bash {
	# First and foremost we must have modern bash and jq
	if [[ "$BASH_VERSION" =~ ^3.*$ ]]; then
		echo "Bash 3 installed... please install bash (brew/apt/etc install bash)" 1>&2
		echo "if you have already done that ensure you aren't calling with an alias to MacOS bash (which defaults to 3, and is where this usually happens)" 1>&2
		help
		update_e
		exit 1
	fi
}

# exit early if this has been run recently
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

# check for latest
function check_for_latest {
	# TODO: add a flag to make all of this optional (or maybe optional by default)
	# TODO: add a check that ensures this is checked at generalrc
	# TODO: do the tooling checks as well (maybe as part of the tooling)
	local old_dir="$(pwd)"
	local exit_code=0
	local error_message=""
	local basic_setup_dir="$(general-get-basic-setup-dir)"
	{
		cd "$basic_setup_dir"
		if [ ! -z "$(git status --porcelain)" ]; then
			error_message="Error checking for latest, git not porcelain at ${basic_setup_dir}."
			false
		else
			git fetch -p
			local diff="$(git rev-list main...origin/main --count)"
			if (( $diff > 0 )); then
				# TODO: offer an interactive way to update here
				error_message="Branch 'main' not at latest, please update ${basic_setup_dir}"
				false
			else
				(( $VERBOSITY > 0 )) && echo "at latest" || true
				if [ "$(git branch --show-current)" != "$TARGET_BRANCH" ]; then
					error_message="Git "
					false
				fi
			fi
		fi
	} || {
		local exit_code=$?
		if (( $exit_code == 0 )); then
			local exit_code=1
		fi
		if [ -z "$error_message" ]; then
			local error_message="error during environment-validation when checking for latest..."
		fi
	}
	cd "$old_dir"
	if (( $exit_code > 0 )); then
		echo "$error_message" 1>&2
		exit $exit_code
	fi
}

# Check for the tools described in the packages after filtering
function check_for_tools {
	# TODO: merge config override
	# Merge file paths - https://stackoverflow.com/a/36218044
	# jq -s 'reduce .[] as $item ({}; . * $item)'
	# this will need to be done per item to ensure they are there
	# TODO: handle the different ways we want to handle filters
	local packages_keys="$(echo $PACKAGES | jq -r '.packages[] | select((.labels[] | . == "'${LABELS[0]}'") and .enabled == true) | .name')"
	echo "$packages_keys" | while read package_key; do
		(($VERBOSITY > 1)) && echo "running for $package_key"
		local package_content="$(echo "$PACKAGES" | jq '.packages[] | select(.name == "'"$package_key"'")')"
		should_be_installed "$package_content"
	done
}

# ensure the OS specific tooling is installed (e.g. GNU Mac tools)
function check_for_os_specific_tooling {
	# TODO: find a way to force gnu-sed on OSX - https://gist.github.com/andre3k1/e3a1a7133fded5de5a9ee99c87c6fa0d
	if [ "$(environment-os-type --mac)" == "true" ]; then
		if [ "$(brew list --formula | grep coreutils)" != "coreutils" ]; then
			echo "unable to find coreutils. Install with brew install coreutils" 1>&2
			help
			update_e
			exit 1
		fi
	fi
}

# fail after running everything to generate a list
function handle_overall_errors {
	if (( "${#ERROR_MESSAGES[@]}" > 0 )); then
		echo "Found Failures: " 1>&2
		for error_message_object in "${ERROR_MESSAGES[@]}"; do
			error_message=$(echo $error_message_object | jq -r '.message')
			if [ -z "$error_message" ]; then
				continue
			fi
			echo "  - $error_message" 1>&2
		done
		help
		update_e
		exit 1
	fi
}

# Get the install command for the package manager
function get_package_manager_install_command {
	local package_manager="$1"
	local package="$2"
	local install_command="unknown install command"
	[ "$package_manager" == "apt-get" ] && local install_command="apt-get install $package"
	[ "$package_manager" == "brew" ] && local install_command="brew install $package"
	[ "$package_manager" == "curl" ] && local install_command="environment-curl-commands-${package}"
	[ "$package_manager" == "pacman" ] && local install_command="pacman -S $package"
	[ "$package_manager" == "yum" ] && local install_command="yum install $package"
	[ "$package_manager" == "winget" ] && local install_command="winget install -e --id $package"
	echo "$install_command"
}

# run the logic for a package that should be installed
function should_be_installed {
	local package_content=$1

	local command_name=$(echo "$package_content" | jq -r '.command')
	local is_command_installed=$(is_command_installed "$command_name")
	if (( $is_command_installed == 0 )); then
		# TODO: handle installs here if flag passed
		local human_name=$(echo "$package_content" | jq -r '.name')
		local extra=$(echo "$package_content" | jq -r '."install-page"')
		local package_manager_content="$(get_package_manager_content "$package_content")"
		local package_name="$human_name"
		local package_manager_name=""
		local package_manager_install_command="Manually install ${package_name}."
		if [ ! -z "$package_manager_content" ]; then
			local package_name=$(echo "$package_manager_content" | jq '."package-name"')
			local package_manager_name=$(echo "$package_manager_content" | jq '."manager-name"')
			local package_manager_install_command=$(get_package_manager_install_command "$package_manager_name" "$package_name")
		fi
		local message="unable to find $human_name ($command_name), '$package_manager_install_command' $extra"
		local error_message=$(echo "$package_content" | jq -c --arg m "$message" '{message: $m} + .')
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
		update_e
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
[ $SHOW_HELP == true ] && help && update_e && exit 0

check_for_skip
check_for_latest
check_for_jq
check_for_bash
check_for_os_specific_tooling
check_for_tools
handle_overall_errors

# If everything worked, note it so that future checks can be skipped
touch "${BASIC_SETUP_DATA_DIRECTORY}${PREVIOUSLY_VALIDATED_FILE_NAME}"

update_e
