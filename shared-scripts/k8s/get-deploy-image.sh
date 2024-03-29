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
ALL_INFO=false
NAME=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_NAME:-""}
NAMESPACE=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_NAMESPACE:-""}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$NAME" ]; then
	NAME=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_NAME:-""}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_NAMESPACE:-""}
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
		description: get the image for a deployment
		----------
		-a|--all        - (flag, current: $ALL_INFO) Return all images for the deployment instead of just the last one (usually the target image).
		-d|--deployment - (required, current: "$NAME") The name of the deployment to get the image from, also set with \`BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_NAME\`.
		-h|--help       - (flag, current: $SHOW_HELP) Print this help message and exit.
		-n|--namespace  - (optional, current: "$NAMESPACE") The namespace the deployment is in, also set with \`BASIC_SETUP_K8S_CREATE_NODE_SHELL_NAMESPACE\`.
		-v|--verbose    - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		get deployment image(s) - $command_for_help --node "example-node"
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# deployment name, required argument
	-d | --deployment)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			NAME="$2"
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
	*) PARAMS="$PARAMS $1"
		shift
		;;
	esac
done

#
# Do the work
#
[ $SHOW_HELP == true ] && help && exit 0

# error if no name
if [ -z "$NAME" ]; then
	echo "Error: deployment name is required" >&2
	help
	exit 1
fi

# handle additional arguments
ADDITIONAL_ARGS=""
if [ ! -z "$NAMESPACE" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS -n $NAMESPACE"
fi

DEPLOY_INFO=$(kubectl get deployment $ADDITIONAL_ARGS $NAME -o json)
if [ -z "$DEPLOY_INFO" ]; then
	echo "Error: deployment $NAME not found" >&2
	exit 1
fi

CONTAINERS=$(echo "$DEPLOY_INFO" | jq -r '.spec.template.spec.containers')
if [ -z "$CONTAINERS" ]; then
	echo "Error: deployment $NAME has no containers" >&2
	exit 1
fi

if [ "$ALL_IMAGES" == true ]; then
	echo "$CONTAINERS" | jq -r '.[].image'
else
	echo "$CONTAINERS" | jq -r '. | last | .image'
fi
