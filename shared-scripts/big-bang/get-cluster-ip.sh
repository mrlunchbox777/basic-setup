#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -l "big-bang" -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
SHOW_HELP=false
CLUSTER_NAME="${BASIC_SETUP_BIG_BANG_GET_CLUSTER_IP_CLUSTER_NAME:-""}"
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$CLUSTER_NAME" ]; then
	CLUSTER_NAME="${BASIC_SETUP_BIG_BANG_GET_CLUSTER_IP_CLUSTER_NAME:-"k3d-k3s-default"}"
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
		description: gets the IP of the k3d cluster
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-n|--name    - (optional, current: "$CLUSTER_NAME") the name of the cluster, also set with \`BASIC_SETUP_BIG_BANG_GET_CLUSTER_IP_CLUSTER_NAME\`.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		login to the default registry - $command_for_help
		----------
		note: this only works for single cluster kubeconfigs
		---
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
	# name optional argument
	-n | --name)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			CLUSTER_NAME="$2"
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

# This seems like it'll only work for single cluster kubeconfigs
yq '.clusters[] | select(.name == "'$CLUSTER_NAME'").cluster.server' ~/.kube/config | sed 's|^http[s]*://||' | sed 's|:6443$||'
