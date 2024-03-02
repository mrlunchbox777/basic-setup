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
TARGET_DIR="./"
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
		description: count the number of lines in a directory
		----------
		-d|--dir     - (optional, current: "$TARGET_DIR") The directory to count lines in.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		count lines in current directory - $command_for_help
		count lines in target directory  - $command_for_help -d target
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
	# directory to count lines in, optional argument
	-d | --dir)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			TARGET_DIR="$2"
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

find "$TARGET_DIR" -type f | sed "s/^/'/;s/$/'/" | xargs cat | wc -l
