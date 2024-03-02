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
SEARCH_DIR="./"
SHOW_HELP=false
TARGET_DIR=""
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
		description: find a directory by name
		----------
		-d|--dir      - (required, current: "$TARGET_DIR") The directory to count lines in.
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-m|--maxdepth - (optional, current: "$MAX_DEPTH") The maximum depth to search recursively.
		-s|--search   - (optional, current: "$SEARCH_DIR") The directory to search in.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		find .config/                - $command_for_help -d .config -s ~
		find bin dirs in current dir - $command_for_help -d bin
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# directory to find, required argument
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
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# maximum depth, optional argument
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
	# search directory, optional argument
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

# error if no target directory is specified
if [ -z "$TARGET_DIR" ]; then
	echo "Error: No directory specified" >&2
	help
	exit 1
fi

# error if no search directory is specified
if [ -z "$SEARCH_DIR" ]; then
	echo "Error: No search directory specified" >&2
	help
	exit 1
fi

# error if the search directory doesn't exist
if [ ! -d "$SEARCH_DIR" ]; then
	echo "Error: Search directory does not exist: $SEARCH_DIR" >&2
	help
	exit 1
fi

# error if max depth is not a number
if ! [[ "$MAX_DEPTH" =~ ^[0-9]+$ ]]; then
	echo "Error: Max depth is not a number: $MAX_DEPTH" >&2
	help
	exit 1
fi

sudo find "$SEARCH_DIR" -maxdepth $MAX_DEPTH -type d -iname "$TARGET_DIR"
