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
PASSWORD=${BAISIC_SETUP_BIG_BANG_HELM_LOGIN_PASSWORD:-""}
REGISTRY=${BAISIC_SETUP_BIG_BANG_HELM_LOGIN_REGISTRY:-""}
SHOW_HELP=false
USER_REGISTRY_CREDENTIALS=true
USERNAME=${BAISIC_SETUP_BIG_BANG_HELM_LOGIN_USERNAME:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$PASSWORD" ]; then
	PASSWORD=${BAISIC_SETUP_BIG_BANG_HELM_LOGIN_PASSWORD:-""}
fi
if [ -z "$REGISTRY" ]; then
	REGISTRY=${BAISIC_SETUP_BIG_BANG_HELM_LOGIN_REGISTRY:-"registry1.dso.mil"}
fi
if [ -z "$USERNAME" ]; then
	USERNAME=${BAISIC_SETUP_BIG_BANG_HELM_LOGIN_USERNAME:-""}
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
		description: runs helm registry login, with good defaults
		----------
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-p|--password - (optional, current: "$(echo "$PASSWORD" | sed 's/./*/g')") password for the registry, will pull from registry-values.yaml override file if empty, can be set with \`BAISIC_SETUP_BIG_BANG_HELM_LOGIN_PASSWORD\`.
		-r|--registry - (optional, current: "$REGISTRY") registry to login to, can be set with \`BAISIC_SETUP_BIG_BANG_HELM_LOGIN_REGISTRY\`.
		-u|--username - (optional, current: "$USERNAME") username for the registry, will pull from registry-values.yaml override file if empty, can be set with \`BAISIC_SETUP_BIG_BANG_HELM_LOGIN_USERNAME\`.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
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

helm registry login "$REGISTRY" --username "$USERNAME" --password "$PASSWORD"
