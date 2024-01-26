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
NAMESPACE=""
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
		description: set the current kubernetes namespace
		----------
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace to search in, default interactive.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		set namespace interactively - $command_for_help
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
	# namespace argument, optional
	-n | --namespace)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			NAMESPACE="$2"
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

# Thanks to Matthew Anderson for the powershell function that this was adapted from
NAMESPACES=$(kubectl get namespaces -o json | jq '.items | .[].metadata.name' | sed 's/\"//g')
NAMESPACE="$1"
if [ -z "$NAMESPACE" ]; then
	CURRENT_NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}'; echo)
	NAMESPACE_COUNT=$(echo "$NAMESPACES" | wc -l)
	echo "Select Kubernetes Namespace"
	for i in $(seq 1 $NAMESPACE_COUNT); do
		echo "$i - $(echo "$NAMESPACES" | sed -n "$i"p)"
	done
	read -p "Which namespace to use (current - $CURRENT_NAMESPACE)?: " REPLY_VALUE
	(($VERBOSITY>1)) && echo "reply - $REPLY_VALUE"
	if [[ "$REPLY_VALUE" =~ ^[0-9]*$ ]] && [ "$REPLY_VALUE" -le "$NAMESPACE_COUNT" ] && [ "$REPLY_VALUE" -gt "0" ]; then
		NAMESPACE=$(echo "$NAMESPACES" | sed -n "$REPLY_VALUE"p)
		(($VERBOSITY>0)) && echo $NAMESPACES
		(($VERBOSITY>0)) && echo "selected $NAMESPACE"
	else
		echo "Entry invalid, exiting..." >&2
		return 1
	fi
else
	NAMESPACE_EXISTS=$(kubectl get ns $NAMESPACE --no-headers --ignore-not-found)
	if [ -z "$NAMESPACE_EXISTS" ]; then
		echo "Namespace invalid, exiting..." >&2
		return 1
	fi
fi
kubectl config set-context --current --namespace="$NAMESPACE"
