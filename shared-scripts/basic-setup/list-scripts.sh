#! /usr/bin/env bash

#
# global defaults
#
SHOW_HELP=false

GREP_STRING=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_GREP_STRING:-""}
USE_ALL=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_ALL:-""}
USE_ALIASES=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_ALIASES:-""}
USE_BIG_BANG=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_BIG_BANG:-""}
USE_BIN=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_BIN:-""}
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
if [ -z "$GREP_STRING" ]; then
	GREP_STRING=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_GREP_STRING:-""}
fi
if [ -z "$USE_ALL" ]; then
	USE_ALL=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_ALL:-false}
fi
if [ -z "$USE_ALIASES" ]; then
	USE_ALIASES=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_ALIASES:-false}
fi
if [ -z "$USE_BIG_BANG" ]; then
	USE_BIG_BANG=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_BIG_BANG:-false}
fi
if [ -z "$USE_BIN" ]; then
	USE_BIN=${BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_BIN:-true}
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
		description: Lists scripts managed by basic-setup.
		----------
		-a|--all      - (flag, current: $USE_ALL) List all scripts, also set with \`BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_ALL\`.
		--aliases     - (flag, current: $USE_ALIASES) List aliases, also set with \`BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_ALIASES\`.
		-b|--big-bang - (flag, current: $USE_BIG_BANG) List big bang scripts, also set with \`BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_BIG_BANG\`.
		--bin         - (flag, current: $USE_BIN) List bin scripts, pass --bin to turn it off, also set with \`BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_USE_BIN\`.
		-g|--grep     - (optional string, current: "$GREP_STRING") Grep the list of scripts for the given string, also set with \`BASIC_SETUP_BASIC_SETUP_LIST_SCRIPTS_GREP_STRING\`.
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		list all scripts      - $command_for_help -a
		list aliases only     - $command_for_help --aliases --bin
		list bin and big-bang - $command_for_help -b
		grep bin for general  - $command_for_help -g "general"
		----------
	EOF
}

# list all scripts for a given directory
list_scripts() {
	local dir="$1"
	local script_list="$(ls "$dir")"
	if [ -n "$GREP_STRING" ]; then
		local script_list="$(echo "$script_list" | grep "$GREP_STRING")"
	fi
	echo "$script_list"
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# all flag
	-a | --all)
		USE_ALL=true
		shift
		;;
	# aliases flag
	--aliases)
		USE_ALIASES=true
		shift
		;;
	# big-bang flag
	-b | --big-bang)
		USE_BIG_BANG=true
		shift
		;;
	# bin flag
	--bin)
		USE_BIN=false
		shift
		;;
	# the grep string, optional argument
	-g | --grep)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			GREP_STRING="$2"
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

(($VERBOSITY > 0)) && echo "--"
(($VERBOSITY > 0)) && echo "Scripts:"
basic_setup_dir="$(general-get-basic-setup-dir)"

if [ $USE_ALIASES == true ] || [ $USE_ALL == true ]; then
	(($VERBOSITY > 0)) && echo ""
	(($VERBOSITY > 0)) && echo "Aliases:"
	list_scripts "${basic_setup_dir}/shared-scripts/alias/bin"
fi

if [ $USE_BIG_BANG == true ] || [ $USE_ALL == true ]; then
	(($VERBOSITY > 0)) && echo ""
	(($VERBOSITY > 0)) && echo "Big Bang:"
	list_scripts "${basic_setup_dir}/shared-scripts/big-bang/bin" | grep -v "^\.gitkeep$"
fi

if [ $USE_BIN == true ] || [ $USE_ALL == true ]; then
	(($VERBOSITY > 0)) && echo ""
	(($VERBOSITY > 0)) && echo "Bin:"
	list_scripts "${basic_setup_dir}/shared-scripts/bin"
fi

(($VERBOSITY > 0)) && echo "--"

exit 0
