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
SCRIPT_PATH="typescript"
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
		description: read a \`script\` file and remove all ANSI escape sequences
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-s|--script  - (optional, current: "$SCRIPT_PATH") The path to the script to read.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		read a script - $command_for_help -s "typescript"
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
	# script path, optional argument
	-s | --script)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			SCRIPT_PATH=$2
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

# error if the script path is empty
if [ -z "$SCRIPT_PATH" ]; then
	echo "Error: script (-s) is required" >&2
	help
	exit 1
fi

# error if the script doesn't exist
if [ ! -f "$SCRIPT_PATH" ]; then
	echo "Error: script (-s) file does not exist: $SCRIPT_PATH" >&2
	help
	exit 1
fi

cat "$SCRIPT_PATH" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
