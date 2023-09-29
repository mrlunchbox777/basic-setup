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
CLUSTER_USER="ubuntu"
CLUSTER_IP=""
VERBOSITY=0
AWS_USERNAME=""
SSH_KEY_PATH=""

#
# computed values (often can't be alphabetical)
#
DEFAULT_AWS_USERNAME=$(aws sts get-caller-identity | jq -r '.Arn' | sed 's|.*/||')
DEFAULT_SSH_KEY_PATH="${HOME}/.ssh/${DEFAULT_AWS_USERNAME}-dev.pem"

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
		description: runs helm registry login, with good defaults
		----------
		-a|--aws-username - (optional, default: "$DEFAULT_AWS_USERNAME") the AWS username to use for the SSH key, -s takes precedence.
		-h|--help         - (flag, default: false) Print this help message and exit.
		-i|--ip           - (optional, default: "") the IP of the cluster, found with \`big-bang-get-cluster-ip\` if blank.
		-n|--name         - (optional, default: "$CLUSTER_NAME") the name of the cluster.
		-s|--ssh-key      - (optional, default: "$DEFAULT_SSH_KEY_PATH") the path to the SSH key to use, takes precedence over -a.
		-u|--user         - (optional, default: "$CLUSTER_USER") the user to SSH into the cluster as.
		-v|--verbose      - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		login to the default registry - $command_for_help
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# aws-username optional argument
	-a | --aws-username)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			AWS_USERNAME="$2"
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
	# ip optional argument
	-i | --ip)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			CLUSTER_IP="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
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
	# ssh-key optional argument
	-s | --ssh-key)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			SSH_KEY_PATH="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# user optional argument
	-u | --user)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			CLUSTER_USER="$2"
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

if [ -z "$CLUSTER_IP" ]; then
	CLUSTER_IP="$(big-bang-get-cluster-ip -n "$CLUSTER_NAME")"
fi

if [ -z "$SSH_KEY_PATH" ]; then
	SSH_KEY_PATH="$DEFAULT_SSH_KEY_PATH"
fi

if [ -z "$SSH_KEY_PATH" ] && [ ! -z "$AWS_USERNAME" ]; then
	SSH_KEY_PATH="${HOME}/.ssh/${AWS_USERNAME}-dev.pem"
fi

if [ ! -f "$SSH_KEY_PATH" ]; then
	echo "Error: SSH key not found at $SSH_KEY_PATH" >&2
	exit 1
fi

ssh $CLUSTER_USER@$CLUSTER_IP -i $SSH_KEY_PATH
