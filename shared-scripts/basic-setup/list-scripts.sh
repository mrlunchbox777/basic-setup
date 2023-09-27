#! /usr/bin/env bash

#
# global defaults
#
USE_ALL=false
USE_ALIASES=false
USE_BIG_BANG=false
USE_BIN=true
GREP_STRING=""
SHOW_HELP=false
VERBOSITY=0

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
		-a|--all       - (flag, default: false) List all scripts.
		--aliases      - (flag, default: false) List aliases.
		-b|--big-bang  - (flag, default: false) List big bang scripts.
		--bin          - (flag, default: true) List bin scripts, pass --bin to turn it off.
		-g|--grep      - (optional string, default: "") Grep the list of scripts for the given string.
		-h|--help      - (flag, default: false) Print this help message and exit.
		-v|--verbose   - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		list all scripts      - $command_for_help -a
		list aliases          - $command_for_help --aliases --bin
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
