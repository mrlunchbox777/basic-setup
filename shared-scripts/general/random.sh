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
MIN=0
MAX=10
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
		description: generate a random number between two values, max can be at most 32767
		----------
		-h|--help        - (flag, current: $SHOW_HELP) Print this help message and exit.
		-l|--lower|--min - (optional, current: $MIN) The minimum value to return.
		-u|--upper|--max - (optional, current: $MAX) The maximum value to return.
		-v|--verbose     - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		get a random number between 0 and 10 - $command_for_help
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
	# min, optional argument
	-l | --lower | --min)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			MIN=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# max, optional argument
	-u | --upper | --max)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			MAX=$2
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

# error if min is greater than max
if (( $MIN > $MAX )); then
	echo "Error: min ($MIN) is greater than max ($MAX)" >&2
	exit 1
fi

# error if min is equal to max
if (( $MIN == $MAX )); then
	echo "Error: min ($MIN) is equal to max ($MAX)" >&2
	exit 1
fi

# error if min is less than 0
if (( $MIN < 0 )); then
	echo "Error: min ($MIN) is less than 0" >&2
	exit 1
fi

# error if max is greater than 32767
if (( $MAX > 32767 )); then
	echo "Error: max ($MAX) is greater than 32767" >&2
	exit 1
fi

tempminvar=$1
if [ -z "$tempminvar" ]; then
	tempminvar=0
fi
tempmaxvar=$2
if [ -z "$tempmaxvar" ]; then
	tempmaxvar=10
fi
MAX=$(($MAX-$MIN+1))
RANDOM_VAL=$((RANDOM))
echo $(($MIN + ($RANDOM_VAL % $MAX)))
