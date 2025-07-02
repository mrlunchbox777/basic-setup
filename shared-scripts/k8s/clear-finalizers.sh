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
ALL_NAMESPACES=${BASIC_SETUP_K8S_CLEAR_FINALIZERS_ALL_NAMESPACES:-""}
NAMESPACE=${BASIC_SETUP_K8S_CLEAR_FINALIZERS_NAMESPACE:-""}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$ALL_NAMESPACES" ]; then
	ALL_NAMESPACES=${BASIC_SETUP_K8S_CLEAR_FINALIZERS_ALL_NAMESPACES:-"true"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_CLEAR_FINALIZERS_NAMESPACE:-"kube-system"}
fi
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
		description: clear finalizers from a namespace, or all namespaces
		----------
		-a|--all-namespaces - (flag, current: $ALL_NAMESPACES) Clear finalizers from all namespaces, will be ignored if namespace (-n) is set, also set with \`BASIC_SETUP_K8S_CLEAR_FINALIZERS_ALL_NAMESPACES\`.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace to search in, defaults to all (-a), also set with \`BASIC_SETUP_K8S_CLEAR_FINALIZERS_NAMESPACE\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		clear all finalizers - $command_for_help
		clear finalizers in a namespace - $command_for_help -n "my-namespace"
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# all namespaces flag
	-a | --all-namespaces)
		ALL_NAMESPACES=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# namespace, optional argument
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

# set all namespaces flag
if [ ! -z "$NAMESPACE" ]; then
	ALL_NAMESPACES=false
fi

# clear finalizers
if [ $ALL_NAMESPACES == true ]; then
	namespaces="$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')"
	for ns in $namespaces; do
		kubectl get ns $ns -o json | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/$ns/finalize -f -
	done
else
	kubectl get ns $NAMESPACE -o json | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/$NAMESPACE/finalize -f -
fi
