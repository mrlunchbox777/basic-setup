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
PASSWORD=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_PASSWORD:-""}
REGISTRY=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_REGISTRY:-""}
SHOW_HELP=false
USER_REGISTRY_CREDENTIALS=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_USER_REGISTRY_CREDENTIALS:-""}
USERNAME=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_USERNAME:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$PASSWORD" ]; then
	PASSWORD=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_PASSWORD:-""}
fi
if [ -z "$REGISTRY" ]; then
	REGISTRY=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_REGISTRY:-"registry1.dso.mil"}
fi
if [ -z "$USER_REGISTRY_CREDENTIALS" ]; then
	USER_REGISTRY_CREDENTIALS=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_USER_REGISTRY_CREDENTIALS:-true}
fi
if [ -z "$USERNAME" ]; then
	USERNAME=${BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_USERNAME:-""}
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi

#
# helper functions
#

# TODO: support a local bigbang deploy (for bringing in a new addon)
# script help message
function help {
	command_for_help="$(basename "$0")"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: runs docker login, with good defaults
		----------
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-p|--password - (optional, current: "$PASSWORD") password for the registry, will pull from registry-values.yaml override file if empty, also set with \`BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_PASSWORD\`.
		-r|--registry - (optional, current: "$REGISTRY") registry to login to, also set with \`BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_REGISTRY\`.
		-u|--username - (optional, current: "$USERNAME") username for the registry, will pull from registry-values.yaml override file if empty, also set with \`BASIC_SETUP_BIG_BANG_DOCKER_LOGIN_USERNAME\`.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
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
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# password optional argument
	-p | --password)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			PASSWORD="$2"
			USER_REGISTRY_CREDENTIALS=false
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# registry optional argument
	-r | --registry)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			REGISTRY="$2"
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
			USERNAME="$2"
			USER_REGISTRY_CREDENTIALS=false
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

if [ $USER_REGISTRY_CREDENTIALS == true ]; then
	. big-bang-export-registry-credentials
	USERNAME="$REGISTRY_USERNAME"
	PASSWORD="$REGISTRY_PASSWORD"
fi

[ -z "$USERNAME" ] && echo "Error: username is required" >&2 && help && exit 1
[ -z "$PASSWORD" ] && echo "Error: password is required" >&2 && help && exit 1

docker login "$REGISTRY" --username "$USERNAME" --password "$PASSWORD"
