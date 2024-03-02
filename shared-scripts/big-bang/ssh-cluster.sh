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
AWS_USERNAME=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_AWS_USERNAME:-""}
CLUSTER_IP=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_IP:-""}
CLUSTER_NAME=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_NAME:-""}
CLUSTER_USER=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_USER:-""}
SHOW_HELP=false
SSH_KEY_PATH=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_SSH_KEY_PATH:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
DEFAULT_AWS_USERNAME=$(aws sts get-caller-identity | jq -r '.Arn' | sed 's|.*/||')
DEFAULT_SSH_KEY_PATH="${HOME}/.ssh/${DEFAULT_AWS_USERNAME}-dev.pem"
if [ -z "$AWS_USERNAME" ]; then
	AWS_USERNAME=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_AWS_USERNAME:-"$DEFAULT_AWS_USERNAME"}
fi
if [ -z "$CLUSTER_IP" ]; then
	CLUSTER_IP=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_IP:-""}
fi
if [ -z "$CLUSTER_NAME" ]; then
	CLUSTER_NAME=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_NAME:-"k3d-k3s-default"}
fi
if [ -z "$CLUSTER_USER" ]; then
	CLUSTER_USER=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_USER:-"ubuntu"}
fi
if [ -z "$SSH_KEY_PATH" ]; then
	SSH_KEY_PATH=${BASIC_SETUP_BIG_BANG_SSH_CLUSTER_SSH_KEY_PATH:-"$DEFAULT_SSH_KEY_PATH"}
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
		description: runs helm registry login, with good defaults
		----------
		-a|--aws-username - (optional, current: "$AWS_USERNAME") the AWS username to use for the SSH key, -s takes precedence, also set with \`BASIC_SETUP_BIG_BANG_SSH_CLUSTER_AWS_USERNAME\`.
		-h|--help         - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--ip           - (optional, current: "$CLUSTER_IP") the IP of the cluster, found with \`big-bang-get-cluster-ip\` if blank, also set with \`BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_IP\`.
		-n|--name         - (optional, current: "$CLUSTER_NAME") the name of the cluster, also set with \`BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_NAME\`.
		-s|--ssh-key      - (optional, current: "$SSH_KEY_PATH") the path to the SSH key to use, takes precedence over -a, also set with \`BASIC_SETUP_BIG_BANG_SSH_CLUSTER_SSH_KEY_PATH\`.
		-u|--user         - (optional, current: "$CLUSTER_USER") the user to SSH into the cluster as, also set with \`BASIC_SETUP_BIG_BANG_SSH_CLUSTER_CLUSTER_USER\`.
		-v|--verbose      - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
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
