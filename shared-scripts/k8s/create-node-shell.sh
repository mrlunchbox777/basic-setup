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
COMMAND_TO_RUN=${BASIC_SETUP_K8S_CREATE_NODE_SHELL_COMMAND:-""}
IMAGE_TO_USE=${BASIC_SETUP_K8S_CREATE_NODE_SHELL_IMAGE_TO_USE:-""}
NAMESPACE=${BASIC_SETUP_K8S_CREATE_NODE_SHELL_NAMESPACE:-""}
NODE_NAME=""
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
	COMMAND_TO_RUN=${BASIC_SETUP_K8S_CREATE_NODE_SHELL_COMMAND:-""}
fi
if [ -z "$IMAGE_TO_USE" ]; then
	IMAGE_TO_USE=${BASIC_SETUP_K8S_CREATE_NODE_SHELL_IMAGE_TO_USE:-"$BASIC_SETUP_ALPINE_IMAGE_TO_USE"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_CREATE_NODE_SHELL_NAMESPACE:-"kube-system"}
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
		description: create a privilleged pod to get a shell on a kubernetes node
		----------
		-c|--command   - (optional, current: "$COMMAND_TO_RUN") The command to run in the shell, also set with \`BASIC_SETUP_K8S_CREATE_NODE_SHELL_COMMAND\`.
		-h|--help      - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--image     - (optional, current: "$IMAGE_TO_USE") The image to use for the pod, also set with \`BASIC_SETUP_K8S_CREATE_NODE_SHELL_IMAGE_TO_USE\`.
		-n|--namespace - (optional, current: "$NAMESPACE") The namespace to create the pod in, also set with \`BASIC_SETUP_K8S_CREATE_NODE_SHELL_NAMESPACE\`.
		-v|--verbose   - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--node         - (optional, current: "$NODE_NAME") The name of the node to get shell on, default interactive.
		----------
		note: this is often blocked by security policies, and is not recommended for production use
		----------
		examples:
		create node shell - $command_for_help --node "example-node"
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
	# node name, required argument
	--node)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			NODE_NAME="$2"
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

# Adapted from https://stackoverflow.com/questions/67976705/how-does-lens-kubernetes-ide-get-direct-shell-access-to-kubernetes-nodes-witho
BASIC_SETUP_DIR=$(general-get-basic-setup-dir)
NODES=$(kubectl get nodes -o=json | jq -r '.items | .[].metadata.name')
if [ -z "$NODE_NAME" ]; then
	node_count=$(echo "$NODES" | wc -l)
	echo "Select Kubernetes Node"
	for i in $(seq 1 $node_count); do
		echo $i $(echo "$NODES" | sed -n "$i"p)
	done
	echo "Which node to use?: " && read
	if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$node_count" ] && [ "$REPLY" -gt "0" ]; then
		NODE_NAME=$(echo $NODES | sed -n "$REPLY"p)
	else
		echo "Entry invalid, exiting..." >&2
		exit 1
	fi
fi
NODE_EXISTS=$(echo "$NODES" | grep "$NODE_NAME")
[ -z "$NODE_EXISTS" ] && echo "No node with the name provided ($NODE_NAME), check below for nodes\n\n--\n$nodes\n--\n\nexiting..." && exit 1
echo "Node found, creating pod to get shell"
POD_NAME=$(echo "node-shell-$(uuid)")
POD_YAML="/tmp/$POD_NAME.yaml"
sed \
	-e "s|\$IMAGE_TO_USE|$IMAGE_TO_USE|g" \
	-e "s|\$POD_NAME|$POD_NAME|g" \
	-e "s|\$NODE_NAME|$NODE_NAME|g" \
	-e "s|\$NAMESPACE|$NAMESPACE|g" \
	"$BASIC_SETUP_DIR/resources/k8s-yaml/node-shell.yaml" > "$POD_YAML"
FAILED="false"
EXCEPTION=""
{
	kubectl apply -f "$POD_YAML"
	echo "Pod scheduled, waiting for running"
	NODE_SHELL_READY="false"
	while [[ "$NODE_SHELL_READY" == "false" ]]; do
		POD_EXISTS=$(kubectl get pod $POD_NAME -n $NAMESPACE --no-headers --ignore-not-found)
		if [ -z "$POD_EXISTS" ]; then
			sleep 1
		else
			CURRENT_PHASE=$(kubectl get pod $POD_NAME -n $NAMESPACE -o=jsonpath="{$.status.phase}")
			if [[ "$CURRENT_PHASE" == "Running" ]]; then
				NODE_SHELL_READY="true"
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
	EXCEPTION="$?"
	FAILED="true"
}

POD_EXISTS=$(kubectl get pods $POD_NAME -n $NAMESPACE --no-headers --ignore-not-found)
if [[ ! -z "$POD_EXISTS" ]]; then
	echo "Cleaning up node-shell pod"
	kubectl delete pod $POD_NAME -n $NAMESPACE
fi

rm "$POD_YAML"

if [[ "$FAILED" == "true" ]]; then
	echo "Failure detected, check logs, exiting...">&2
	echo "exception code - $EXCEPTION">&2
	exit $EXCEPTION
fi
