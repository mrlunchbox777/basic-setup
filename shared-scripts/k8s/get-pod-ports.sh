#! /usr/bin/env bash

## TODO: Clean output (will require cleaning output of everything else)

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
ALL_IMAGES=${BASIC_SETUP_K8S_GET_POD_PORT_ALL_IMAGES:-""}
SHOW_HELP=false
LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_PORT_LABEL_KEY:-""}
LABEL_VALUE=""
NAMESPACE=${BASIC_SETUP_K8S_GET_POD_PORT_NAMESPACE:-""}
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
if [ -z "$ALL_IMAGES" ]; then
	ALL_IMAGES=${BASIC_SETUP_K8S_GET_POD_PORT_ALL_IMAGES:-"false"}
fi
if [ -z "$LABEL_KEY" ]; then
	LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY:-"app.kubernetes.io/name"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_NAMESPACE:-""}
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
		description: get the ports for a pod
		----------
		-a|--all-images  - (flag, current: $ALL_IMAGES) Return all images for the deployment, instead of just the last one, also set with \`BASIC_SETUP_K8S_GET_POD_PORT_ALL_IMAGES\`.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--label-value - (required, current: "$LABEL_VALUE") The label value to search for.
		--label-key      - (optional, current: "$LABEL_KEY") The label key to search for, also set with \`BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY\`.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace the deployment is in, also set with \`BASIC_SETUP_K8S_CREATE_NODE_SHELL_NAMESPACE\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		get pod ports - $command_for_help -l "app.kubernetes.io/name=nginx"
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

PODS_BY_NODE=$(echo "$PODS_INFO" | jq -r '.items | group_by(.spec.nodeName)')
(($VERBOSITY > 2)) && echo "# PODS_BY_NODE: $PODS_BY_NODE"
if [ $ALL_IMAGES != true ]; then
	PODS_BY_NODE=$(echo "$PODS_BY_NODE" | jq -r '[. | last]')
fi
PODS_BY_NODE_COUNT=$(echo "$PODS_BY_NODE" | jq -r 'length')

PODS_BY_NODE_OBJ="{}"
for n in $(seq 0 $(($PODS_BY_NODE_COUNT -1))); do
	# get pods on node
	PODS_ON_NODE=$(echo "$PODS_BY_NODE" | jq -r ".[$n]")
	(($VERBOSITY > 3)) && echo "# PODS_ON_NODE: $PODS_ON_NODE"

	# skip if no pods on node
	PODS_ON_NODE_COUNT=$(echo "$PODS_ON_NODE" | jq -r ". | length")
	if [ $PODS_ON_NODE_COUNT -eq 0 ]; then
		(($VERBOSITY > 1)) && echo "# Skipping node $n, no pods on node"
		continue
	fi

	# get node name
	NODE_NAME=$(echo "$PODS_ON_NODE" | jq -r ". | first | .spec.nodeName")
	(($VERBOSITY > 2)) && echo "# NODE_NAME: $NODE_NAME"

	# add pods on node to final pods info
	PODS_ON_NODE_OBJ="{\"$NODE_NAME\": $(echo "$PODS_ON_NODE")}"
	(($VERBOSITY > 3)) && echo "# PODS_ON_NODE_OBJ: $PODS_ON_NODE_OBJ"
	PODS_BY_NODE_OBJ=$(echo "$PODS_BY_NODE_OBJ" | jq -r ". + $PODS_ON_NODE_OBJ")
done

(($VERBOSITY > 3)) && echo "# PODS_BY_NODE_OBJ: $PODS_BY_NODE_OBJ"

# iterate through nodes
for node_name in $(echo "$PODS_BY_NODE_OBJ" | jq -r 'keys | .[]'); do
	(($VERBOSITY > 1)) && echo "# node_name: $node_name"
	# get pods on node
	PODS_ON_NODE=$(echo "$PODS_BY_NODE_OBJ" | jq -r ".[\"$node_name\"]")
	(($VERBOSITY > 3)) && echo "# PODS_ON_NODE: $PODS_ON_NODE"
	PODS_ON_NODE_COUNT=$(echo "$PODS_ON_NODE" | jq -r ". | length")
	(($VERBOSITY > 2)) && echo "# PODS_ON_NODE_COUNT: $PODS_ON_NODE_COUNT"

	FULL_GET_NODE_POD_PORTS_COMMAND="echo '# Running on Node: $node_name' && echo ''"
	ALL_NODE_POD_CONTAINERS=()
	# iterate through pods on node
	for i in $(seq 0 $(($PODS_ON_NODE_COUNT - 1))); do
		# get pod info
		POD_INFO=$(echo "$PODS_ON_NODE" | jq -r ".[$i]")
		(($VERBOSITY > 3)) && echo "# POD_INFO: $POD_INFO"

		# get pod name
		POD_NAME=$(echo "$POD_INFO" | jq -r '.metadata.name')
		(($VERBOSITY > 3)) && echo "# POD_NAME: $POD_NAME"

		# get pod images
		POD_CONTAINER=$(echo "$POD_INFO" | jq -r '.spec.containers')
		ALL_NODE_POD_CONTAINERS+=("$POD_CONTAINER")
		POD_IMAGES=$(echo "$POD_CONTAINER" | jq -r '.[].image')
		(($VERBOSITY > 3)) && echo "# POD_IMAGES: $POD_IMAGES"

		# get pod ports
		# POD_PORTS=$(docker inspect --format='{{.Config.ExposedPorts}}' "$POD_IMAGE")
		for image in $POD_IMAGES; do
			POD_IMAGE="$image"
			(($VERBOSITY > 3)) && echo "# POD_IMAGE: $POD_IMAGE"
			GET_POD_PORTS_COMMAND="docker inspect --format='{{json .Config.ExposedPorts}}' $POD_IMAGE"
			FULL_GET_POD_PORTS_COMMAND="echo '' && echo '# $POD_IMAGE Ports:' && $GET_POD_PORTS_COMMAND && echo ''"
			(($VERBOSITY > 3)) && echo "# ADDING COMMAND: $FULL_GET_POD_PORTS_COMMAND"
			FULL_GET_NODE_POD_PORTS_COMMAND="$FULL_GET_NODE_POD_PORTS_COMMAND && $FULL_GET_POD_PORTS_COMMAND"
		done

		# print pod ports
		# echo "$POD_PORTS"
	done
	(($VERBOSITY > 0)) && echo "# NODE '$NODE_NAME' FULL_GET_NODE_POD_PORTS_COMMAND: \`$FULL_GET_NODE_POD_PORTS_COMMAND\`"
	{
		k8s-create-node-shell --node "$NODE_NAME" -c "$FULL_GET_NODE_POD_PORTS_COMMAND"
	} || {
		# pull images
		for image in "${ALL_NODE_POD_IMAGES[@]}"; do
			if (($VERBOSITY > 0)); then
				docker pull "$image"
			else
				docker pull "$image" 2>&1 >/dev/null
			fi
		done
		(($VERBOSITY > 0)) && echo "# Failed to 'docker inspect' on the node, trying locally..."
		sh -c "echo '# RUNNING LOCALLY' && $FULL_GET_NODE_POD_PORTS_COMMAND"
		(($VERBOSITY > 0)) && echo "# Ran local 'local docker inspect'"
	}
done
