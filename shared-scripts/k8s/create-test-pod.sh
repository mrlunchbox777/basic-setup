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
IMAGE_TO_USE=${BASIC_SETUP_K8S_CREATE_TEST_POD_IMAGE_TO_USE:-""}
NAMESPACE=${BASIC_SETUP_K8S_CREATE_TEST_POD_NAMESPACE:-""}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$IMAGE_TO_USE" ]; then
	IMAGE_TO_USE=${BASIC_SETUP_K8S_CREATE_TEST_POD_IMAGE_TO_USE:-"$BASIC_SETUP_ALPINE_IMAGE_TO_USE"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_CREATE_TEST_POD_NAMESPACE:-"kube-system"}
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
		description: create a test pod in the cluster, default pod is alpine base
		----------
		-h|--help      - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--image     - (optional, current: "$IMAGE_TO_USE") The image to use for the pod, also set with \`BASIC_SETUP_K8S_CREATE_TEST_POD_IMAGE_TO_USE\`.
		-n|--namespace - (optional, current: "$NAMESPACE") The namespace to create the pod in, also set with \`BASIC_SETUP_K8S_CREATE_TEST_POD_NAMESPACE\`.
		-v|--verbose   - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		create test pod - $command_for_help
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
	# image, optional argument
	-i | --image)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			IMAGE_TO_USE="$2"
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

POD_NAME=$(echo "test-pod-$(uuid)")
POD_YAML="/tmp/$POD_NAME.yaml"
sed \
	-e "s|\$IMAGE_TO_USE|$IMAGE_TO_USE|g" \
	-e "s|\$POD_NAME|$POD_NAME|g" \
	-e "s|\$NAMESPACE|$NAMESPACE|g" \
	"$BASIC_SETUP_GENERAL_RC_DIR/../resources/k8s-yaml/test-pod.yaml" > "$POD_YAML"
FAILED="false"
{
	kubectl apply -f "$POD_YAML"
	(($VERBOSITY>0)) && echo "Pod scheduled, waiting for running"
	POD_SHELL_READY="false"
	while [[ "$POD_SHELL_READY" == "false" ]]; do
		POD_EXISTS=$(kubectl get pod $POD_NAME -n $NAMESPACE --no-headers --ignore-not-found)
		if [ -z "$POD_EXISTS" ]; then
			sleep 1
		else
			CURRENT_PHASE=$(kgp $POD_NAME -n $NAMESPACE -o=jsonpath="{$.status.phase}")
			if [[ "$CURRENT_PHASE" == "Running" ]]; then
				POD_SHELL_READY="true"
			else
				sleep 1
			fi
		fi
	done
} || {
	FAILED="true"
}

if [ "$FAILED" == "true" ]; then
	echo "Failed to create pod, see above for details" >&2
	exit 1
fi
