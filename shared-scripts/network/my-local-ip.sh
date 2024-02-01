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
GET_FIRST=""
GET_LAST=""
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
if [ -z "$GET_FIRST" ]; then
	GET_FIRST=${BASIC_SETUP_NETWORK_MY_LOCAL_IP_GET_FIRST:-false}
fi
if [ -z "$GET_LAST" ]; then
	GET_LAST=${BASIC_SETUP_NETWORK_MY_LOCAL_IP_GET_LAST:-false}
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
		description: show the default network device local ip(s), one per line
		----------
		-f|--get-first - (flag, current: $GET_FIRST) Get the first default network device local ip(s), mutually exclusive with last, also set with \`BASIC_SETUP_NETWORK_MY_LOCAL_IP_GET_FIRST\`.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--get-last - (flag, current: $GET_LAST) Get the last default network device local ip(s), mutually exclusive with first, also set with \`BASIC_SETUP_NETWORK_MY_LOCAL_IP_GET_LAST\`.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		show the default network device local ip(s) - $command_for_help
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# get first flag
	-f | --get-first)
		GET_FIRST=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# get last flag
	-l | --get-last)
		GET_LAST=true
		shift
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
if [ $GET_FIRST == true ] && [ $GET_LAST == true ]; then
	echo "Error: -f and -l are mutually exclusive" >&2
	help
	exit 1
fi

# add extra args
EXTRA_ARGS=""
if [ $GET_FIRST == true ]; then
	EXTRA_ARGS="$EXTRA_ARGS -f"
fi
if [ $GET_LAST == true ]; then
	EXTRA_ARGS="$EXTRA_ARGS -l"
fi

DEVICES=$(network-my-default-network-device $EXTRA_ARGS)
echo "$DEVICES" | xargs -I % sh -c "ip addr show | awk \"/%/ {print}\" | tr \" \" \"\\\n\" | awk '/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|(([a-f0-9:]+:+)+[a-f0-9]+)/ {print;exit}' | xargs echo %"
