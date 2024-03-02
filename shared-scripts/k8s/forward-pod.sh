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
BIND_PORT=${BASIC_SETUP_K8S_FORWARD_POD_BIND_PORT:-""}
LABEL_KEY=${BASIC_SETUP_K8S_FORWARD_POD_LABEL_KEY:-""}
LABEL_VALUE=""
NAMESPACE=${BASIC_SETUP_K8S_FORWARD_POD_NAMESPACE:-""}
POD_PORT=${BASIC_SETUP_K8S_FORWARD_POD_POD_PORT:-"80"}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$BIND_PORT" ]; then
	BIND_PORT=${BASIC_SETUP_K8S_FORWARD_POD_BIND_PORT:-""}
fi
if [ -z "$LABEL_KEY" ]; then
	LABEL_KEY=${BASIC_SETUP_K8S_FORWARD_POD_LABEL_KEY:-""}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_FORWARD_POD_NAMESPACE:-""}
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
		description: forward a pod port to localhost and open in browser
		----------
		-b|--bind-port   - (optional, current: "$BIND_PORT") The port to bind to on localhost, defaults to a random port (echoed with verbosity<0), also set with \`BASIC_SETUP_K8S_FORWARD_POD_BIND_PORT\`.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--label-value - (required, current: "$LABEL_VALUE") The label value to search for.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace to search in, defaults to all (-A), also set with \`BASIC_SETUP_K8S_FORWARD_POD_NAMESPACE\`.
		-p|--pod-port    - (optional, current: "$POD_PORT") The port to forward from the pod, also set with \`BASIC_SETUP_K8S_FORWARD_POD_POD_PORT\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--label-key      - (optional, current: "$LABEL_KEY") The label key to search for, also set with \`BASIC_SETUP_K8S_FORWARD_POD_LABEL_KEY\`.
		----------
		note: podinfo is a good pod to test this with, but the default port is 9898 not 80
		----------
		examples:
		forward a pod port - $command_for_help -l "my-app"
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
	# label value argument, required
	-l | --label)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			LABEL_VALUE="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# label key argument, optional
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
	# pod port argument, optional
	-p | --pod-port)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			POD_PORT="$2"
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

# ensure sudo
sudo cat /dev/null

# error if label value is empty
if [ -z "$LABEL_VALUE" ]; then
	echo "Error: label value is empty" >&2
	help
	exit 1
fi

# ensure bind port is available
if [ -z "$BIND_PORT" ]; then
	BIND_PORT=0
	VALID_BIND_PORT=false
	while [ "$VALID_BIND_PORT" == false ]; do
		# find used ports
		USED_PORTS=$(sudo netstat -tulpn | grep LISTEN | awk '{print $4}' | awk -F: '{print $2}' | sort -n | uniq)
		# get an IANA private port
		BIND_PORT=$(general-random -l 49152 -u 65535)
		VALID_BIND_PORT=true
		for used_port in $USED_PORTS; do
			if [ "$used_port" == "$BIND_PORT" ]; then
				VALID_BIND_PORT=false
			fi
		done
	done
	if (( $VERBOSITY > 0 )); then
		echo "Using random port $BIND_PORT"
	fi
fi

# handle additional arguments
ADDITIONAL_ARGS=""
if [ ! -z "$LABEL_VALUE" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS -l $LABEL_VALUE"
fi
if [ ! -z "$LABEL_KEY" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS --label-key $LABEL_KEY"
fi
if [ ! -z "$NAMESPACE" ]; then
	ADDITIONAL_ARGS="$ADDITIONAL_ARGS -n $NAMESPACE"
fi

POD_IDS=$(k8s-get-pod-by-label $ADDITIONAL_ARGS -a)
POD_IDS_COUNT=$(echo "$POD_IDS" | jq -r '.items | length')
if (( $POD_IDS_COUNT == 0 )); then
	echo "No pods found with label $LABEL_KEY=$LABEL_VALUE" >&2
	exit 1
fi
if (( $POD_IDS_COUNT > 1 )); then
	echo "Multiple pods found with label $LABEL_KEY=$LABEL_VALUE" >&2
	echo "$POD_IDS" >&2
	exit 1
fi
POD_ID_NAME=$(echo "$POD_IDS" | jq -r '.items[0].metadata.name')
POD_ID_NAMESPACE=$(echo "$POD_IDS" | jq -r '.items[0].metadata.namespace')

FORWARD_POD_COMMAND="kubectl port-forward -n $POD_ID_NAMESPACE pod/$POD_ID_NAME $BIND_PORT:$POD_PORT"
FAILED="false"
TEMP_FILE_NAME=""
{
	TEMP_FILE_NAME="/tmp/basic-setup-forward-pod-$(uuid).log"
	sh -c "$FORWARD_POD_COMMAND" &> $TEMP_FILE_NAME &
	if (( $VERBOSITY > 1 )); then
		echo "Running command: $FORWARD_POD_COMMAND, logging to $TEMP_FILE_NAME"
	fi
	sleep 1
	FORWARDING_OUTPUT=$(cat $TEMP_FILE_NAME)
	BOUND_PORT=$(echo "$FORWARDING_OUTPUT" | awk '{print $3}' | sed -n 1p | awk -F: '{print $2}')
	if (( $VERBOSITY > 1 )); then
		echo "Forwarding pod $POD_ID_NAME port $POD_PORT to localhost:$BOUND_PORT"
	fi
	# TODO support open for mac here - https://superuser.com/questions/911735/how-do-i-use-xdg-open-from-xdg-utils-on-mac-osx
	xdg-open http://localhost:$BOUND_PORT </dev/null >/dev/null 2>&1 & disown
} || {
	FAILED="true"
}

if [[ "$FAILED" == "true" ]]; then
	echo "Failure detected, check logs ($TEMP_FILE_NAME), exiting..." >&2
	exit 1
fi
