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
MESSAGES=()
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
		description: send messages to the console with a timestamp
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-m|--message - (multi-required, current count: ${#MESSAGES[@]}) The messages to send.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		send test message  - $command_for_help -m "test message"
		send test messages - $command_for_help -m "test message 1" -m "test message 2"
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
	# message multi-required argument
	-m | --message)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
		MESSAGES+=("$2")
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

# error if the message is empty
if [ ${#MESSAGES[@]} -eq 0 ]; then
	echo "Error: message (-m) is required" >&2
	help
	exit 1
fi

echo "********************************************************"
echo "*"
echo "* $(date)"
for CURRENT_MESSAGE in "${MESSAGES[@]}"; do echo "* $CURRENT_MESSAGE"; done
echo "*"
echo "********************************************************"
