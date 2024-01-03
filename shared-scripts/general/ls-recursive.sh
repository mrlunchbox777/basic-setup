#! /usr/bin/env bash

# Skipping environment validation for recursive scripts

#
# global defaults
#
TARGET=""
SHOW_HELP=false
VERBOSITY=0

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
		description: recursively list all files in a directory
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-t|--target  - (required, current: $TARGET) The directory to list.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		recursively list all files in the current directory - $command_for_help -t ./
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
	# target, required argument
	-t | --target)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			TARGET=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
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

if [ -z "$TARGET" ]; then
	echo "Missing required argument: -t|--target" >&2
	help
	exit 1
fi

if [ ! -d "$TARGET" ]; then
	echo "Not a directory - $TARGET" >&2
	exit 1
fi
items="$(ls -1aF "$TARGET" | grep -v "^\.*/*$")"
for i in $items; do
	if [[ "$i" =~ /$ ]]; then
		general-ls-recursive -t "${TARGET}${i}"
	else
		echo "${TARGET}${i}"
	fi
done
