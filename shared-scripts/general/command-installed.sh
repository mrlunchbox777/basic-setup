#! /usr/bin/env bash

# NOTE: don't run environment-validation here, it could cause a loop

# TODO: make this more fully fledged

#
# global defaults
#
COMMAND_TO_TEST=""
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
		description: echo if a command is installed
		----------
		-c|--command - (required, current: "$COMMAND_TO_TEST") The command to test for.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		check if \`command\` is installed  - $command_for_help -c command
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# command to test, optional argument
	-c | --command)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			COMMAND_TO_TEST="$2"
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

# TODO: support commands that work differently like omz, nvm, moreutils, etc.
# TODO: consolidate on returning true or false, returning 0 or 1, exiting 0 or 1, etc.
(($(command -v "$COMMAND_TO_TEST" >/dev/null 2>&1; echo $?) == 0)) && echo true || echo false
