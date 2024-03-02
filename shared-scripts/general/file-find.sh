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
MAX_DEPTH=2147483647
TARGET_FILE=""
SHOW_HELP=false
SEARCH_DIR="./"
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
		description: find a file by name
		----------
		-f|--file     - (required, current: "$TARGET_FILE") The file to find.
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-m|--maxdepth - (optional, current: "$MAX_DEPTH") The maximum depth to search recursively.
		-s|--search   - (optional, current: "$SEARCH_DIR") The directory to search in.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		find .bashrc                  - $command_for_help -f .bashrc -s ~
		find README.md in current dir - $command_for_help -f README.md
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# file to find, required argument
	-f | --file)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			TARGET_FILE="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	-m | --maxdepth)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			MAX_DEPTH="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# directory to search, optional argument
	-s | --search)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			SEARCH_DIR="$2"
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

# error if no file is specified
if [ -z "$TARGET_FILE" ]; then
	echo "Error: No file specified" >&2
	help
	exit 1
fi

# error if no directory is specified
if [ -z "$SEACH_DIR" ]; then
	echo "Error: No directory specified" >&2
	help
	exit 1
fi

# error if the directory doesn't exist
if [ ! -d "$SEACH_DIR" ]; then
	echo "Error: Directory does not exist: $SEACH_DIR" >&2
	help
	exit 1
fi

# error if max depth is not a number
if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
	echo "Error: Max depth is not a number: $MAX_DEPTH" >&2
	help
	exit 1
fi

sudo find "$SEACH_DIR" -maxdepth $MAX_DEPTH -type f -iname "$TARGET_FILE"
