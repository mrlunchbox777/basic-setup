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
RETURN_ALL=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_RETURN_ALL:-""}
LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY:-""}
LABEL_VALUE=""
NAMESPACE=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_NAMESPACE:-""}
SHOW_HELP=false
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
if [ -z "$LABEL_KEY" ]; then
	LABEL_KEY=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY:-"app.kubernetes.io/name"}
fi
if [ -z "$NAMESPACE" ]; then
	NAMESPACE=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_NAMESPACE:-""}
fi
if [ -z "$RETURN_ALL" ]; then
	RETURN_ALL=${BASIC_SETUP_K8S_GET_POD_BY_LABEL_RETURN_ALL:-"false"}
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
		description: get a pod by label
		----------
		-a|--return-all  - (flag, current: $RETURN_ALL) Return the raw kubectl output, in json, instead of the pod-id.
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--label-value - (required, current: "$LABEL_VALUE") The label value to search for.
		--label-key      - (optional, current: "$LABEL_KEY") The label key to search for, also set with \`BASIC_SETUP_K8S_GET_POD_BY_LABEL_KEY\`.
		-n|--namespace   - (optional, current: "$NAMESPACE") The namespace to search in, defaults to all (-A), also set with \`BASIC_SETUP_K8S_GET_POD_BY_LABEL_NAMESPACE\`.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: use the recommended labels for your app, see https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/
		    - default label key: app.kubernetes.io/name
		----------
		examples:
		get pod by app label - $command_for_help -l "my-app"
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# return all flag
	-a | --return-all)
		RETURN_ALL=true
		shift
		;;
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

# error if label value is empty
if [ -z "$LABEL_VALUE" ]; then
	echo "Error: Argument for -l|--label is missing" >&2
	help
	exit 1
fi

# handle namespace
ADDITIONAL_ARGS=""
if [ ! -z "$NAMESPACE" ]; then
	ADDITIONAL_ARGS="-n $NAMESPACE"
else
	ADDITIONAL_ARGS="-A"
fi

RAW_OUTPUT=$(kubectl get pods $ADDITIONAL_ARGS -l "$LABEL_KEY"="$LABEL_VALUE" -o json)
if [ "$RETURN_ALL" == "true" ]; then
	echo "$RAW_OUTPUT"
else
	echo "$RAW_OUTPUT" | jq -r '.items[0].metadata.name'
fi
