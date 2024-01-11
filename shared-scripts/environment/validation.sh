#! /usr/bin/env bash

#
# Skip everything if this is set
#
if [ "$BASIC_SETUP_SKIP_ENVIRONMENT_VALIDATION" == "true" ]; then
	exit 0
fi

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
# TODO: make more/all of these configurable
BASIC_SETUP_DATA_DIRECTORY="$HOME/.basic-setup/"
CUSTOM_LABELS=false
ERROR_MESSAGES=0
LABELS=("core")
FORCE=false
PREVIOUSLY_VALIDATED_FILE_NAME=".environment_validated_by_environment-validation"
RUN_INSTALLS=false
SHOW_HELP=false
SUPPORTED_PACKAGE_MANAGERS=("apt-get" "brew" "curl" "pacman" "dnf" "winget")
TARGET_BRANCH="main"
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# Skip everything if this is set
#
if [ "$BASIC_SETUP_SKIP_ENVIRONMENT_VALIDATION" == "true" ]; then
	exit 0
fi

#
# computed values (often can't be alphabetical)
#
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
ALLOW_CURL_INSTALLS="${BASIC_SETUP_ENVIRONMENT_VALIDATION_ALLOW_CURL_INSTALLS:-false}"
DEFAULT_OVERRIDE_DIR="$(general-get-basic-setup-dir)/resources/install/index.d"
PACKAGES="$(cat "$(general-get-basic-setup-dir)/resources/install/index.json")"
# TODO: make this override do something
PACKAGES_OVERRIDE_DIR="${BASIC_SETUP_ENVIRONMENT_VALIDATION_INDEX_OVERRIDE_DIRECTORY_PATH:-$DEFAULT_OVERRIDE_DIR}"
PACKAGES_OVERRIDE_DIR="$([ ! -z "$PACKAGES_OVERRIDE_DIR" ] && [ -d "$PACKAGES_OVERRIDE_DIR" ] && echo "$PACKAGES_OVERRIDE_DIR" || echo "")"
SKIP_LATEST_CHECK="${BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_LATEST_CHECK:-false}"
SKIP_PORCELAIN="${BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_PORCELAIN:-false}"
SKIP_EVERYTHING="${BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_EVERYTHING:-false}"
TARGET_BRANCH="${BASIC_SETUP_ENVIRONMENT_VALIDATION_TARGET_BRANCH:-$TARGET_BRANCH}"

# TODO: add verbosity to everything

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
		-c|--allow-curl  - (flag, current: $ALLOW_CURL_INSTALLS) Allow curl installs and validations, this can also be set with 'export BASIC_SETUP_ENVIRONMENT_VALIDATION_ALLOW_CURL_INSTALLS=true'.
		-f|--force       - (flag, current: $FORCE) Force the validation (don't skip if previously passed).
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--install     - (flag, current: $RUN_INSTALLS) Run installs and upgrade as needed instead of erroring.
		-l|--label       - (multi-optional, current: (${LABELS[@]}) The union of label(s) that should be used to filter the packages, any addition will replace the default.
		-s|--skip-latest - (flag, current: $SKIP_LATEST_CHECK) Skip latest check, this can also be set with 'export BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_LATEST_CHECK=true'.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1.
		----------
		note: This script will error out if the environment is misconfigured. It should also tell you what can be done to correct the issue.
		note: This script will not install anything by default, you must pass the -i|--install flag to do so.
		note: Set BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_EVERYTHING to true to skip everything.
		----------
		examples:
		validate environment                                           - $command_for_help
		install/update environment with curl enabled                   - $command_for_help -i -c
		install/update environment with curl enabled with all packages - $command_for_help -i -c -l all
		----------
	EOF
}

# ensure a specific command is installed
function is_command_installed {
	general-command-installed -c "$1"
}

# select the correct package manager and return it's content for a given package
function get_package_manager_content {
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
	PREVIOUSLY_VALIDATED_FILE_NAME="${PREVIOUSLY_VALIDATED_FILE_NAME}_$(echo "${LABELS[@]}" | sed 's/ /_/g')_${ALLOW_CURL_INSTALLS}"
	mkdir -p $BASIC_SETUP_DATA_DIRECTORY
	if [ "$FORCE" != "true" ] && [ "$(find "$BASIC_SETUP_DATA_DIRECTORY" -maxdepth 1 -name $PREVIOUSLY_VALIDATED_FILE_NAME -mmin -1440)" ]; then
	# TODO: add verbose and push this out
	# echo "previously validated - skipping" 1>&2
		update_e
		exit 0
	fi
}

# check for latest
function check_for_latest_basic_setup_git {
	# TODO: add a flag to make all of this optional (or maybe optional by default)
	# TODO: add a check that ensures this is checked at generalrc
	# TODO: do the tooling checks as well (maybe as part of the tooling)
	local old_dir="$(pwd)"
	local exit_code=0
	local error_message=""
	local basic_setup_dir="$(general-get-basic-setup-dir)"
	{
		cd "$basic_setup_dir"
		if [ ! -z "$(git status --porcelain)" ] && [ "$SKIP_PORCELAIN" != "true" ]; then
			error_message="Error checking for latest, git not porcelain at ${basic_setup_dir}. Please commit/stash your changes. You can also skip this step with \`export BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_PORCELAIN=\"true\"\`"
			false
		else
			git fetch -p
			local current_branch="$(git branch --show-current)"
			local upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u})"
			local diff="$(git rev-list ${current_branch}...${upstream} --count)"
			if [[ -z "$diff" ]]; then
				error_message="Error checking for latest, git unable to get diff on branch $current_branch. Please ensure you have a remote set up. You can also skip this step with \`export BASIC_SETUP_ENVIRONMENT_VALIDATION_SKIP_PORCELAIN=\"true\"\`"
				false
			fi
			if (( $diff > 0 )); then
				# TODO: offer an interactive way to update here
				error_message="Branch '${current_branch}' not at latest (or you haven't pushed your changes), please update ${basic_setup_dir} or run \`basic-setup-update\` for main."
				false
			else
				(( $VERBOSITY > 0 )) && echo "Git is at latest" || true
				if [ "$current_branch" != "$TARGET_BRANCH" ]; then
					error_message="Git (at ${basic_setup_dir}) is not on the target branch (${TARGET_BRANCH}). It is on ${current_branch}. You can change the target with \`export BASIC_SETUP_ENVIRONMENT_VALIDATION_TARGET_BRANCH=\"$current_branch\"\`."
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
	local labels="$(printf '%s\n' "${LABELS[@]}" | jq -R . | jq -sc .)"
	(($VERBOSITY > 0)) && echo "checking for tools with labels: ${labels[@]}"
	local packages_keys="$(echo $PACKAGES | jq -r '.packages[] | select(any(.labels; . | contains('$labels')) and .enabled == true) | .name')"
	while read package_key; do
		(($VERBOSITY > 1)) && echo "running for $package_key"
		local package_content="$(echo "$PACKAGES" | jq '.packages[] | select(.name == "'"$package_key"'")')"
		should_be_installed "$package_content"
	done <<< $packages_keys # can't use echo pipe because that puts the loop in a subshell
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
	if (( $ERROR_MESSAGES > 0 )); then
		echo "Found Failures, check logs. Run with -h for help." 1>&2
		echo "For install or upgrade errors you can run \`environment-validation\` with:" 1>&2
		echo "  -i to install" 1>&2
		echo "  -c to allow curl-commands" 1>&2
		echo "  -l for each of the current labels - ${LABELS[@]}" 1>&2
		update_e
		exit 1
	else
		(($VERBOSITY > 0)) && echo "No errors found. count - $ERROR_MESSAGES" || true
	fi
}

# Get the install command for the package manager
function get_package_manager_install_command {
	local package_manager="$1"
	local package="$2"
	local install_command="unknown install command"
	(($VERBOSITY > 1)) && echo "finding install command for $package_manager and $package" 1>&2
	[ "$package_manager" == "apt-get" ] && local install_command="sudo apt-get install $package -y"
	[ "$package_manager" == "brew" ] && local install_command="brew install $package"
	[ "$package_manager" == "curl" ] && local install_command="environment-curl-commands-${package} -f -i"
	[ "$package_manager" == "pacman" ] && local install_command="sudo pacman -S --noconfirm $package"
	[ "$package_manager" == "dnf" ] && local install_command="sudo dnf install $package -y"
	[ "$package_manager" == "winget" ] && local install_command="winget install -e --id $package"
	echo "$install_command"
}

# Check for the latest packages
function check_for_latest_package_from_package_manager {
	if [ "$SKIP_LATEST_CHECK" == true ]; then
		return 0
	fi
	local package_manager="$1"
	if [ "$(is_command_installed "$package_manager")" != true ]; then
		return 0
	fi
	local package="$2"
	(($VERBOSITY > 1)) && echo "checking for latest for $package_manager and $package" 1>&2
	if [ "$package_manager" == "apt-get" ]; then
		sudo apt-get update -y > /dev/null
		local apt_results="$(apt-get --just-print upgrade | grep '^[0-9]* upgraded, [0-9]* newly installed, [0-9]* to remove and [0-9]* not upgraded\.$')"
		if [[ "$apt_results" =~ [1-9] ]]; then
			if [ "$RUN_INSTALLS" == false ]; then
				echo "ERROR: Please upgrade apt packages, 'sudo apt upgrade'." 1>&2
				update_e
				exit 1
			else
				(($VERBOSITY > 1)) && echo "found newer packages for apt, upgrading..." 1>&2
				sudo apt-get upgrade -y
				sudo apt-get autoremove -y
			fi
		fi
	fi
	if [ "$package_manager" == "brew" ]; then
		if [ ! -z "$(brew outdated)" ]; then
			if [ "$RUN_INSTALLS" == false ]; then
				echo "ERROR: Please upgrade brew packages 'brew upgrade'." 1>&2
				update_e
				exit 1
			else
				(($VERBOSITY > 1)) && echo "found newer packages for brew, upgrading..." 1>&2
				brew upgrade
			fi
		fi
	fi
	if [ "$package_manager" == "curl" ]; then
		local curl_command="environment-curl-commands-${package}"
		if (( $($curl_command -t >/dev/null 2>&1; echo $?) > 0 )); then
			if [ "$RUN_INSTALLS" == false ]; then
				echo "ERROR: ${package} is out of date. Please run '$curl_command -f -i' (or -h for help)." 1>&2
				update_e
				exit 1
			else
				(($VERBOSITY > 1)) && echo "found newer packages for curl, upgrading..." 1>&2
				$curl_command -f -i
			fi
		fi
	fi
	if [ "$package_manager" == "pacman" ]; then
		if [ ! -z "$(pacman -Qu)" ]; then
			if [ "$RUN_INSTALLS" == false ]; then
				echo "ERROR: Please upgrade pacman packages 'pacman -Syu'." 1>&2
				update_e
				exit 1
			else
				(($VERBOSITY > 1)) && echo "found newer packages for pacman, syncing..." 1>&2
				sudo pacman -Syu
			fi
		fi
	fi
	if [ "$package_manager" == "dnf" ]; then
		if [ ! -z "$(dnf check-update -q)" ]; then
			if [ "$RUN_INSTALLS" == false ]; then
				echo "ERROR: Please upgrade dnf packages 'dnf update'." 1>&2
				update_e
				exit 1
			else
				(($VERBOSITY > 1)) && echo "found newer packages for dnf, updating..." 1>&2
				sudo dnf update -y
			fi
		fi
	fi
	if [ "$package_manager" == "winget" ]; then
		# TODO: implement this WINDOWS
		# https://learn.microsoft.com/en-us/windows/package-manager/winget/list#list-with-update
		(($VERBOSITY > 0)) && echo "not implemented...." 1>&2
	fi
}

# run the logic for a package that should be installed
function should_be_installed {
	local package_content=$1
	local command_name=$(echo "$package_content" | jq -r '.command')
	local is_command_installed=$(is_command_installed "$command_name")
	local human_name=$(echo "$package_content" | jq -r '.name')
	local extra=$(echo "$package_content" | jq -r '."install-page"')
	local package_manager_content="$(get_package_manager_content "$package_content")"
	local package_name="$human_name"
	local package_manager_name=""
	local package_manager_install_command="Manually install $human_name."
	if [ ! -z "$package_manager_content" ]; then
		local package_name=$(echo "$package_manager_content" | jq -r '."package-name"')
		local package_manager_name=$(echo "$package_manager_content" | jq -r '."manager-name"')
		local package_manager_install_command=$(get_package_manager_install_command "$package_manager_name" "$package_name")
	fi
	if [ "$is_command_installed" == "false" ]; then
		if [ "$RUN_INSTALLS" == false ]; then
			(($VERBOSITY > 1)) && echo "$command_name failed"
			local message="unable to find $human_name ($command_name), '$package_manager_install_command' - $extra"
			echo "$message" 1>&2
			((ERROR_MESSAGES+=1))
		else
			# TODO: maybe batch these
			$package_manager_install_command
		fi
	else
		(($VERBOSITY > 0)) && echo "$command_name already installed with $package_manager_name." || true
		if [ "$package_manager_name" == "curl" ]; then
			check_for_latest_package_from_package_manager "$package_manager_name" "$package_name"
		fi
	fi
}

# check for updates
function update_tools {
	for i in $SUPPORTED_PACKAGE_MANAGERS; do
		check_for_latest_package_from_package_manager "$i" all
	done
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# Allow Curl flag
	-c | --allow-curl)
		ALLOW_CURL_INSTALLS=true
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
	# run installs flag
	-i | --install)
		RUN_INSTALLS=true
		shift
		;;
	# label multi-optional argument
	-l | --label)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			if [ $CUSTOM_LABELS == false ]; then
				LABELS=()
				CUSTOM_LABELS=true
			fi
			LABELS+=("$2")
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# skip latest check flag
	-s | --skip-latest)
		SKIP_LATEST_CHECK=true
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
[ "$SKIP_EVERYTHING" == true ] && update_e && exit 0

check_for_skip
check_for_latest_basic_setup_git
check_for_jq
check_for_bash
check_for_os_specific_tooling
check_for_tools
update_tools
handle_overall_errors

# If everything worked, note it so that future checks can be skipped
touch "${BASIC_SETUP_DATA_DIRECTORY}${PREVIOUSLY_VALIDATED_FILE_NAME}"

update_e
