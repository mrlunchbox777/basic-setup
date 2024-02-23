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
TARGET_STRING=""
TRIM_NUMBER_OF_CHARACTERS=0
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
		description: trim a number of characters from the end of a string
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-n|--number  - (required, current: $TRIM_NUMBER_OF_CHARACTERS) The number of characters to trim from the end of the string.
		-s|--string  - (required, current: $TARGET_STRING) The string to trim.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		trim 3 char file type - $command_for_help -s "file.txt" -n 4
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
	# number of characters to trim
	-n | --number)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			TRIM_NUMBER_OF_CHARACTERS=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# string to trim
	-s | --string)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			TARGET_STRING=$2
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

if [ -z "$TARGET_STRING" ]; then
	echo "Error: Argument for -s|--string is missing" >&2
	help
	exit 1
fi

if ! [[ $TRIM_NUMBER_OF_CHARACTERS =~ ^[0-9]+$ ]]; then
	echo "Error: Argument for -n|--number must be a number" >&2
	help
	exit 1
fi

sed 's/.\{'$TRIM_NUMBER_OF_CHARACTERS'\}$//' <<<"$TARGET_STRING"
