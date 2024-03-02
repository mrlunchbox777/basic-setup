#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -l "big-bang" -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
SHOW_HELP=false
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
		description: Returns the full path of the the bigbang directory
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		get bigbang repo dir - $command_for_help
		----------
	EOF
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

bigbang_k3d_path=$(find ./ -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find $HOME/src -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find $HOME/ -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find /home/ -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find / -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
if [ ! -f "$bigbang_k3d_path" ]; then
	echo -e "error finding the k3d-dev script in the bigbang repo..." >&2
	exit 1
fi

bigbang_path="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(echo $bigbang_k3d_path)")")")")")"
if [ ! -d "$bigbang_path" ]; then
	echo -e "error finding the bigbang repo..." >&2
	exit 1
fi

echo "$bigbang_path"
