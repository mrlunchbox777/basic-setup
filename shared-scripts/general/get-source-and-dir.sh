#! /usr/bin/env bash

# Adapted from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script

# skip environment validation so that running a *.rc file doesn't take forever

#
# global defaults
#
DIR=""
SOURCE=""
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
		description: get the source and dir of a script
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-s|--source  - (required, current: $SOURCE) The source to resolve, see below for more info.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		notes:
		to get script source per shell use the following:
		* sh - source="\$0"
		* bash - source="\${BASH_SOURCE[0]}"
		* zsh - source="\${(%):-%x}"

		output - sd={"source": "\$source", "dir": "\$dir"}
		.source - the source resolving symlinks relative to calling pwd
		.dir - the absolute parent dir of .source
		----------
		examples:
		get source and dir - sd="\$($command_for_help -s "\$source")"; source="\$(echo "\$sd" | jq -r .source)"; dir="\$(echo "\$sd" | jq -r .dir)"
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
	# source, required argument
	-s | --source)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			SOURCE="$2"
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

if [ -z "$SOURCE" ]; then
	echo "-s was empty" >&2
	help
	# only error if we are in an interactive shell
	[[ $- =~ i ]] && exit 1 || exit 0
fi

# resolve $source until the file is no longer a symlink
while [ -L "$SOURCE" ]; do
	DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	SOURCE="$(readlink "$SOURCE")"
	# if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	[[ $SOURCE != /* ]] && \
		SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
SOURCE="$DIR/$(basename "$SOURCE")"
echo "{\"source\": \"$SOURCE\", \"dir\": \"$DIR\"}"
