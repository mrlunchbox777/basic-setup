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
CONTEXT=""
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
		description: set the current kubernetes context
		----------
		-c|--context - (optional, current: "$CONTEXT") The kubernetes context to use, default interactive.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		set context interactively - $command_for_help
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# context argument, required
	-c | --context)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			CONTEXT="$2"
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

# Thanks to Matthew Anderson for the powershell function that this was adapted from
if [ -z "$CONTEXT" ]; then
	CONTEXTS=$(kubectl config get-contexts -o name)
	CURRENT_CONTEXT=$(kubectl config current-context)
	CONTEXT_COUNT=$(echo "$CONTEXTS" | wc -l)
	echo "Select Kubernetes Context"
	for i in $(seq 1 $CONTEXT_COUNT); do
		echo $i $(echo "$CONTEXTS" | sed -n "$i"p)
	done
	echo "Which context to use (current - $CURRENT_CONTEXT)?: " && read -r REPLY_VALUE
	if [[ "$REPLY_VALUE" =~ ^[0-9]*$ ]] && [ "$REPLY_VALUE" -le "$CONTEXT_COUNT" ] && [ "$REPLY_VALUE" -gt "0" ]; then
		CONTEXT=$(echo $CONTEXTS | sed -n "$REPLY_VALUE"p)
	else
		echo "Entry invalid, exiting..." >&2
		return 1
	fi
else
	CONTEXT_EXISTS=$(kcgc -o name | grep $CONTEXT)
	if [ -z "$CONTEXT_EXISTS" ]; then
		echo "Context name invalid, exiting..." >&2
		return 1
	fi
fi
kubectl config use-context $CONTEXT
