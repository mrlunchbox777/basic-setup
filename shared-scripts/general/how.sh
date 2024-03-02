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
AFTER_CONTEXT=0
BEFORE_CONTEXT=3
COMMAND=""
LANGUAGE="sh"
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if (( $AFTER_CONTEXT == 0 )); then
	AFTER_CONTEXT=$(( $BEFORE_CONTEXT + 2))
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi

#
# helper functions
#

# script help message
help() {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: Like which, but with more context.
		----------
		-a|--after    - (optional, current: $AFTER_CONTEXT) The amount of context to grab after, only applies if -c is a script.
		-b|--before   - (optional, current: $BEFORE_CONTEXT) The amount of context to grab before, only applies if -c is a script.
		-c|--command  - (required, current: $COMMAND) The command to search for.
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--language - (optional, current: "$LANGUAGE") The command to search for, only applies if -c is a script.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1.
		----------
		note: this will run down the chain of aliases and/or symbolic links until it finds the actual command.
		note: howa is an alias for this command that will allow you to "how" other aliases. It's parameters are positional rather than flags.
		  -c="\$1 -b="\$2" -a="\$3" -l="\$4" -v="\$5"
		    note: the first parameter (-c) is required, the rest are optional.
		    note: the fifth parameter (-v) here takes a number, not a multi-flag.
		  So you can run "howa howa" to see how the howa alias works.
		----------
		examples:
		check source of how - $command_for_help -c how
		----------
	EOF
}

# source and call the how function
how_function() {
	shared_scripts_dir=$(get-shared-scripts-dir)
	. "$shared_scripts_dir/bin/general-how-function"
	how-function "$COMMAND" "$BEFORE_CONTEXT" "$AFTER_CONTEXT" "$LANGUAGE" "$VERBOSITY"
}

#
# CLI parsing
#
PARAMS=""
# while [ $# -gt 0 ]; do
while (("$#")); do
	case "$1" in
	# after optional argument
	-a | --after)
		# if [ -n "$2" ] && [ "$(echo "1 + ${#2}" | bc)" -eq "$(echo "$2" | sed 's/^\-//' | wc -m)" ]; then
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			AFTER_CONTEXT=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# before optional argument
	-b | --before)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			BEFORE_CONTEXT=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# command required argument
	-c | --command)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			COMMAND=$2
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
	# language optional argument
	-l | --language)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			LANGUAGE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# verbosity multi-flag
	-v | --verbose)
		# VERBOSITY=$(echo "$VERBOSITY + 1" | bc)
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
		# TODO: support positional arguments
		PARAMS="$PARAMS $1"
		shift
		;;
	esac
done

#
# Do the work
#
# [ "$(echo "SHOW_HELP" | sed 's/true//' | wc -m)" -eq 1 ] && help && exit 0
[ $SHOW_HELP == true ] && help && exit 0

[ -z "$COMMAND" ] && echo "Error: Argument for -c is missing" >&2 && help && exit 1
how_function
