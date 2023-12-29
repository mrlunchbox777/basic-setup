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
CLUSTER_NAME="k3d-k3s-default"
VERBOSITY=0

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
		-h|--help    - (flag, default: false) Print this help message and exit.
		-n|--name    - (optional, default: "$CLUSTER_NAME") the name of the cluster.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
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
