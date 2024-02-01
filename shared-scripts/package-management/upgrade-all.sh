#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -c -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
SHOW_HELP=false
# no curl
# TODO: support more package managers
SUPPORTED_PACKAGE_MANAGERS=("apt-get" "brew" "pacman" "dnf" "winget")
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
		description: upgrade all for all of the supported package managers
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		upgrade packages - $command_for_help
		----------
	EOF
}

upgrade_for_package_manager() {
	package_manager=$1
	# check if the package manager is installed
	if [ "$(general-command-installed -c "$package_manager")" == "false" ]; then
		(($VERBOSITY>0)) && echo "Skipping $package_manager, not installed"
		return
	fi
	(($VERBOSITY>1)) && echo "Upgrading $package_manager"
	case $package_manager in
		"apt-get")
			sudo apt-get update -y
			sudo apt-get -u upgrade --assume-no
			sudo apt-get upgrade -y
			sudo apt-get autoremove -y
			;;
		"brew")
			brew update
			brew upgrade
			brew cleanup
			;;
		"pacman")
			sudo pacman -Syu
			;;
		"dnf")
			sudo dnf check-update
			sudo dnf upgrade
			;;
		"winget")
			winget upgrade --all
			;;
	esac
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
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

# iterate over all supported package managers
for package_manager in "${SUPPORTED_PACKAGE_MANAGERS[@]}"; do
	upgrade_for_package_manager "$package_manager"
done
