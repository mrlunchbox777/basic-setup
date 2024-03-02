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
ALL_LOGS=${BASIC_SETUP_K8S_GET_POD_LOGS_ALL_LOGS:-""}
LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_LOGS_LABEL_KEY:-""}
LABEL_VALUE=""
NAMESPACE=${BASIC_SETUP_K8S_GET_POD_LOGS_NAMESPACE:-""}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$ALL_LOGS" ]; then
	ALL_LOGS=${BASIC_SETUP_K8S_GET_POD_LOGS_ALL_LOGS:-"false"}
fi
if [ -z "$LABEL_KEY" ]; then
	LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_LOGS_LABEL_KEY:-"app.kubernetes.io/name"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_GET_POD_LOGS_NAMESPACE:-""}
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
		description: get the logs for a pod
		----------
		-a|--all-logs    - (flag, current: $ALL_LOGS) Return all images for the deployment, instead of just the last one, also set with \`BASIC_SETUP_K8S_GET_DEPLOY_IMAGE_ALL_IMAGES\`.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--label-value - (required, current: "$LABEL_VALUE") The label value to search for.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace the deployment is in, also set with \`BASIC_SETUP_K8S_GET_POD_LOGS_NAMESPACE\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		--label-key      - (optional, current: "$LABEL_KEY") The label key to search for, also set with \`BASIC_SETUP_K8S_GET_POD_LOGS_LABEL_KEY\`.
		----------
		examples:
		get pod logs - $command_for_help -l "my-app" -n "my-namespace"
		----------
	EOF
}

# get the logs for a pod given the "podinfo" json
function get-logs-for-pod {
	local pod_info="$1"
	local pod_info_namespace=$(echo "$pod_info" | jq -r '.metadata.namespace')
	local pod_info_name=$(echo "$pod_info" | jq -r '.metadata.name')
	(($VERBOSITY > 0)) && echo "Logs for pod \`$pod_info_name\` in namespace \`$pod_info_namespace\`:"
	kubectl logs -n "$pod_info_namespace" "$pod_info_name"
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# all logs flag
	-a | --all-logs)
		ALL_LOGS=true
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

if [ $ALL_LOGS == true ]; then
	for i in $(seq 0 $(($PODS_INFO_COUNT - 1))); do
		POD_INFO=$(echo "$PODS_INFO" | jq -r ".items[$i]")
		get-logs-for-pod "$POD_INFO"
	done
else
	POD_INFO=$(echo "$PODS_INFO" | jq -r ".items | last")
	get-logs-for-pod "$POD_INFO"
fi
