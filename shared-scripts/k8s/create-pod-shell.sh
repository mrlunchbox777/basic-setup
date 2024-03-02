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
COMMAND_TO_RUN=${BASIC_SETUP_K8S_CREATE_POD_SHELL_COMMAND:-""}
IMAGE_TO_USE=${BASIC_SETUP_K8S_CREATE_POD_SHELL_IMAGE_TO_USE:-""}
NAMESPACE=${BASIC_SETUP_K8S_CREATE_POD_SHELL_NAMESPACE:-""}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$COMMAND_TO_RUN" ]; then
	COMMAND_TO_RUN=${BASIC_SETUP_K8S_CREATE_POD_SHELL_COMMAND:-""}
fi
if [ -z "$IMAGE_TO_USE" ]; then
	IMAGE_TO_USE=${BASIC_SETUP_K8S_CREATE_POD_SHELL_IMAGE_TO_USE:-"$BASIC_SETUP_ALPINE_IMAGE_TO_USE"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_CREATE_POD_SHELL_NAMESPACE:-"kube-system"}
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
		description: execute an interactive command (default (ba)sh) in a kubernetes pod
		----------
		-c|--command   - (optional, current: "$COMMAND_TO_RUN") The command to run in the shell, also set with \`BASIC_SETUP_K8S_CREATE_POD_SHELL_COMMAND\`.
		-h|--help      - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--image     - (optional, current: "$IMAGE_TO_USE") The image to use for the pod, also set with \`BASIC_SETUP_K8S_CREATE_POD_SHELL_IMAGE_TO_USE\`.
		-n|--namespace - (optional, current: "$NAMESPACE") The namespace to create the pod in, also set with \`BASIC_SETUP_K8S_CREATE_POD_SHELL_NAMESPACE\`.
		-v|--verbose   - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		create pod shell - $command_for_help
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# command, required argument
	-c | --command)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			COMMAND_TO_RUN="$2"
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

POD_NAME=$(echo "pod-shell-$(uuid)")
POD_YAML="/tmp/$POD_NAME.yaml"
# TODO make this make sense for windows nodes
sed \
	-e "s|\$IMAGE_TO_USE|$IMAGE_TO_USE|g" \
	-e "s|\$POD_NAME|$POD_NAME|g" \
	-e "s|\$NAMESPACE|$NAMESPACE|g" \
	"$BASIC_SETUP_GENERAL_RC_DIR/../resources/k8s-yaml/test-pod.yaml" > "$POD_YAML"
FAILED="false"
{
	kubectl apply -f "$POD_YAML"
	echo "Pod scheduled, waiting for running"
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
	if [ -z "$COMMAND_TO_RUN" ]; then
		COMMAND_TO_RUN="(( \$(command -v bash >/dev/null 2>&1; echo \$?) == 0 )) && bash || sh"
	fi
	kubectl exec $POD_NAME -n $NAMESPACE -it -- sh -c "$COMMAND_TO_RUN"
} || {
	FAILED="true"
}

POD_EXISTS=$(kubectl get pod $POD_NAME -n $NAMESPACE --no-headers --ignore-not-found)
if [[ ! -z "$POD_EXISTS" ]]; then
	echo "Cleaning up pod-shell pod"
	kubectl delete pod $POD_NAME -n $NAMESPACE
fi
rm "$POD_YAML"

if [[ "$FAILED" == "true" ]]; then
	echo "Failure detected, check logs, exiting..."
	exit 1
fi
