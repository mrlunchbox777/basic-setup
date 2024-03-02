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
START_DATE=""
END_DATE=""
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$END_DATE" ]; then
	END_DATE=$(date)
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
		description: calculate the difference between two iso/rfc dates (in seconds)
		----------
		-e|--end     - (optional, current: "$END_DATE") The end date to compare to, must be in iso/rfc format.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-s|--start   - (required, current: "$START_DATE") The start date to compare to, must be in iso/rfc format.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		find difference between two dates    - $command_for_help -s 2020-01-01 -e 2020-01-02
		find difference between date and now - $command_for_help -s 2020-01-01
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# end date, optional argument
	-e|--end)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			END_DATE="$2"
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
	# start date, required argument
	-s|--start)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			START_DATE="$2"
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

# error if no start date is specified
if [ -z "$START_DATE" ]; then
	echo "Error: No start date specified" >&2
	help
	exit 1
fi

START_SECONDS=$(date +%s -d "$START_DATE")
END_SECONDS=$(date +%s -d "$END_DATE")
DIFF=$(( $END_SECONDS-$START_SECONDS ))
echo $DIFF
