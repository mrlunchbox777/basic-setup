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
ALL_IMAGES=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_ALL_IMAGES:-""}
LABEL_KEY=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_LABEL_KEY:-""}
LABEL_VALUE=""
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
if [ -z "$ALL_IMAGES" ]; then
	ALL_IMAGES=${BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_ALL_IMAGES:-"false"}
fi
if [ -z "$LABEL_KEY" ]; then
	LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY:-"app.kubernetes.io/name"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_NAMESPACE:-""}
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
		-a|--all-images  - (flag, current: $ALL_IMAGES) Return all images for the deployment, instead of just the last one, also set with \`BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_ALL_IMAGES\`.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--label-value - (required, current: "$LABEL_VALUE") The label value to search for.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace the deployment is in, also set with \`BASIC_SETUP_K8S_CREATE_NODE_SHELL_NAMESPACE\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--label-key      - (optional, current: "$LABEL_KEY") The label key to search for, also set with \`BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY\`.
		----------
		examples:
		get deployment image - $command_for_help -l "my-deployment"
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# all images flag
	-a | --all-images)
		ALL_IMAGES=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# label value, required argument
	-l | --label-value)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			LABEL_VALUE="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# label key, optional argument
	--label-key)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			LABEL_KEY="$2"
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

# error if label value is missing
if [ -z "$LABEL_VALUE" ]; then
	echo "Error: label value is required" >&2
	help
	exit 1
fi

# handle additional arguments
ADDITIONAL_ARGS=""
if [ ! -z "$NAMESPACE" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS -n $NAMESPACE"
fi
if [ ! -z "$LABEL_KEY" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS --label-key $LABEL_KEY"
fi

PODS_INFO=$(k8s-get-pod-by-label -l "$LABEL_VALUE" $ADDITIONAL_ARGS -a)
PODS_INFO_COUNT=$(echo "$PODS_INFO" | jq -r '.items | length')

if [ $PODS_INFO_COUNT -eq 0 ]; then
	echo "No pods found with label \`$LABEL_KEY=$LABEL_VALUE\`" >&2
	exit 1
fi

for i in $(seq 0 $(($PODS_INFO_COUNT - 1))); do
	POD_INFO=$(echo "$PODS_INFO" | jq -r ".items[$i]")
	POD_INFO_NAMESPACE=$(echo "$POD_INFO" | jq -r '.metadata.namespace')
	POD_INFO_NAME=$(echo "$POD_INFO" | jq -r '.metadata.name')
	CONTAINERS=$(echo "$POD_INFO" | jq -r '.spec.containers')
	if [ -z "$CONTAINERS" ]; then
		echo "Error: deployment $NAME has no containers" >&2
		exit 1
	fi

	if [ "$ALL_IMAGES" == true ]; then
		echo "$CONTAINERS" | jq -r '.[].image'
	else
		echo "$CONTAINERS" | jq -r '. | last | .image'
	fi
done
