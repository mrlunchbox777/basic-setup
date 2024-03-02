#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -c -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	# exit 1
fi

#
# global defaults
#
IDENTIFIER=""
NAMESPACE=${BASIC_SETUP_K8S_GET_LABELS_BY_NAME_NAMESPACE:-""}
RESOURCE_KIND=${BASIC_SETUP_K8S_GET_LABELS_BY_NAME_RESOURCE_KIND:-"pod"}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_GET_LABELS_BY_NAME_NAMESPACE:-"kube-system"}
fi
if [ -z "$RESOURCE_KIND" ]; then
	RESOURCE_KIND=${BASIC_SETUP_K8S_GET_LABELS_BY_NAME_RESOURCE_KIND:-"pod"}
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
		description: get labels for a resource by name in json format
		----------
		-h|--help          - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--identifier    - (required, current: "$IDENTIFIER") The identifier to search for, e.g. (most likely) name.
		-n|--namespace     - (optional, current: "$NAMESPACE") The namespace to create the pod in, also set with \`BASIC_SETUP_K8S_GET_LABELS_BY_NAME_NAMESPACE\`.
		-r|--resource-kind - (optional, current: "$RESOURCE_KIND") The resource kind to get labels from, also set with \`BASIC_SETUP_K8S_GET_LABELS_BY_NAME_RESOURCE_KIND\`.
		-v|--verbose       - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		get labels for a pod - $command_for_help -i \$(k8s-get-pod-by-label -l "my-app")
		get labels for a pod - $command_for_help -i \$(kgpbl -l "my-app")
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
	# identifier, required argument
	-i | --identifier)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			IDENTIFIER="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
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
	# resource kind, optional argument
	-r | --resource-kind)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			RESOURCE_KIND="$2"
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
	*) PARAMS="$PARAMS $1"
		shift
		;;
	esac
done

#
# Do the work
#
[ $SHOW_HELP == true ] && help && exit 0

# error if no identifier
if [ -z "$IDENTIFIER" ]; then
	echo "Error: identifier is required" >&2
	help
	exit 1
fi

# handle additional arguments
ADDITIONAL_ARGS="$RESOURCE_KIND"
if [ ! -z "$NAMESPACE" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS -n $NAMESPACE"
fi

pod_info=$(kubectl get $ADDITIONAL_ARGS "$IDENTIFIER" -o json)
pod_labels=$(echo "$pod_info" | jq -r '.metadata.labels')
if [ -z "$pod_labels" ]; then
	echo "Error: no labels found for $IDENTIFIER" >&2
	exit 1
fi
echo "$pod_labels"
