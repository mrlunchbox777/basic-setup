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
COMMAND="code"
EXPRESSION=""
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
		description: grep for files containing a given expression and run a command on them.
		----------
		-c|--command  - (optional, current: $COMMAND) The command to run on each file.
		-e|--expression  - (required, current: $EXPRESSION) The expression to search for.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		open found files in code - $command_for_help -e "TODO"
		count lines in found files - $command_for_help -e "TODO" -c "wc -l"
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# command optional argument
	-c | --command)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			COMMAND="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# expression, required argument
	-e | --expression)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			EXPRESSION="$2"
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

# error if expression is empty
if [ -z "$EXPRESSION" ]; then
	echo "-e was empty" >&2
	help
	exit 1
fi

# error if command is empty
if [ -z "$COMMAND" ]; then
	echo "-c was empty" >&2
	help
	exit 1
fi

grep -r "$EXPRESSION" | sed 's/:.*//' | sort -u | xargs -I % sh -c "$COMMAND \"%\""
