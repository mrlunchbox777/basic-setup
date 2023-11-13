#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -l "big-bang" -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2 echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
RUN_IN_BACKGROUND=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_RUN_IN_BACKGROUND:-""}
DOGFOOD_CONFIG_S3_PATH="${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_DOGFOOD_CONFIG_S3_PATH:-""}"
SHOW_HELP=false
FORCE_NEW_CONFIG=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_FORCE_NEW_CONFIG:-""}
DOGFOOD_USER="${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_DOGFOOD_USER:-""}"
SSHUTTLE_IP_RANGE="${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_SSHUTTLE_IP_RANGE:-""}"
PRIVATE_KEY_PATH="${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_PRIVATE_KEY_PATH:-""}"
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$RUN_IN_BACKGROUND" ]; then
	RUN_IN_BACKGROUND=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_RUN_IN_BACKGROUND:-false}
fi
if [ -z "$DOGFOOD_CONFIG_S3_PATH" ]; then
	DOGFOOD_CONFIG_S3_PATH=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_DOGFOOD_CONFIG_S3_PATH:-""}
fi
if [ -z "$FORCE_NEW_CONFIG" ]; then
	FORCE_NEW_CONFIG=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_FORCE_NEW_CONFIG:-false}
fi
if [ -z "$DOGFOOD_USER" ]; then
	DOGFOOD_USER=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_DOGFOOD_USER:-"ec2-user"}
fi
if [ -z "$SSHUTTLE_IP_RANGE" ]; then
	SSHUTTLE_IP_RANGE=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_SSHUTTLE_IP_RANGE:-"192.168.13.0/24"}
fi
if [ -z "$PRIVATE_KEY_PATH" ]; then
	PRIVATE_KEY_PATH=${BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_PRIVATE_KEY_PATH:-"~/.ssh/id_rsa"}
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
		description: runs sshuttle to the dogfood cluster and sets up the kubeconfig
		----------
		-b|--background - (flag, current: $RUN_IN_BACKGROUND) Run sshuttle in the background, also set with \`BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_RUN_IN_BACKGROUND\`.
		-f|--force    - (flag, current: $FORCE_NEW_CONFIG) Force a new dogfood kubeconfig to be downloaded, requires -s, also set with \`BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_FORCE_NEW_CONFIG\`.
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--identity - (optional, current: "$PRIVATE_KEY_PATH") The private key to use for sshuttle, also set with \`BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_PRIVATE_KEY_PATH\`.
		-r|--range    - (optional, current: "$SSHUTTLE_IP_RANGE") The IP range to route through the bastion host, also set with \`BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_SSHUTTLE_IP_RANGE\`.
		-s|--s3-path  - (optional, current: "$DOGFOOD_CONFIG_S3_PATH") The S3 path to the dogfood kubeconfig, also set with \`BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_DOGFOOD_CONFIG_S3_PATH\`.
		-u|--username - (optional, current: "$DOGFOOD_USER") username for the bastion host, also set with \`BASIC_SETUP_BIG_BANG_DOGFOOD_PREP_DOGFOOD_USER\`.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: if you need to download the dogfood kubeconfig you must provide -s, which you can find here - https://repo1.dso.mil/big-bang/team/deployments/bigbang#connecting-to-the-dogfood-api-server.
		----------
		examples:
		prep to connect to the dogfood cluster - $command_for_help
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# background flag
	-b | --background)
		RUN_IN_BACKGROUND=true
		shift
		;;
	# force flag
	-f | --force)
		FORCE_NEW_CONFIG=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# identity optional argument
	-i | --identity)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			PRIVATE_KEY_PATH="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# range optional argument
	-r | --range)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			SSHUTTLE_IP_RANGE="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# s3-path optional argument
	-s | --s3-path)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			DOGFOOD_CONFIG_S3_PATH="$2"
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# username optional argument
	-u | --username)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			DOGFOOD_USER="$2"
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

sudo cat /dev/null # prompt for sudo password now

if [ ! -d ~/.kube ]; then
	mkdir ~/.kube
fi
if [ "$FORCE_NEW_CONFIG" == true ]; then
	rm -f ~/.kube/dogfood.yaml
fi
if [ ! -f ~/.kube/dogfood.yaml ]; then
	if [ -z "$DOGFOOD_CONFIG_S3_PATH" ]; then
		echo "Error: dogfood config not found at ~/.kube/dogfood.yaml and no S3 path provided" >&2
		help
		exit 1
	fi
	aws s3 cp $DOGFOOD_CONFIG_S3_PATH ~/.kube/dogfood.yaml
fi
if [ -f ~/.kube/config ]; then
	mv ~/.kube/config ~/.kube/config-$(date +%s).bak
fi
cp ~/.kube/dogfood.yaml ~/.kube/config

dogfood_host="$(aws ec2 describe-instances --filters Name=tag:Name,Values=dogfood-bastion --output json | jq -r '.Reservations[0].Instances[0].PublicIpAddress')"
ssh-keyscan -t rsa $dogfood_host | ssh-keygen -lf -

# this will need sudo
if [ "$RUN_IN_BACKGROUND" == true ]; then
	sshuttle --dns -vr $DOGFOOD_USER@$dogfood_host $SSHUTTLE_IP_RANGE --ssh-cmd 'ssh -i "'$PRIVATE_KEY_PATH'"' &
else
	sshuttle --dns -vr $DOGFOOD_USER@$dogfood_host $SSHUTTLE_IP_RANGE --ssh-cmd 'ssh -i "'$PRIVATE_KEY_PATH'"'
fi

