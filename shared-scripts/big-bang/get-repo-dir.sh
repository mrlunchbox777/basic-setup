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
BIGBANG_PATH=${BAISC_SETUP_BIG_BANG_GET_REPO_DIR_BIGBANG_PATH:-""}
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$BIGBANG_PATH" ]; then
	BIGBANG_PATH=${BAISC_SETUP_BIG_BANG_GET_REPO_DIR_BIGBANG_PATH:-""}
fi
if (($VERBOSITY == -1)); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi

#
# helper functions
#

# script help message
function help {
	command_for_help="$(basename "$0")"
	cat <<-EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: Returns the full path of the the bigbang directory
		----------
		-b|--bigbang-path - (optional, current: "$BIGBANG_PATH") The path to the bigbang repo, also set with \`BAISC_SETUP_BIG_BANG_GET_REPO_DIR_BIGBANG_PATH\`. If not set, the script will search for the bigbang repo in the following directories: ./, $HOME/src, $HOME/, /home/, /.
		-h|--help         - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose      - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
		----------
		examples:
		get bigbang repo dir - $command_for_help
		----------
	EOF
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# bigbang path argument
	-b | --bigbang-path)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			BIGBANG_PATH="$2"
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
		((VERBOSITY += 1))
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

if [ -z "$BIGBANG_PATH" ]; then
	initial_path="$(pwd)"
else
	initial_path="$BIGBANG_PATH"
fi

relative_k3d_path="*/docs/reference/scripts/developer/k3d-dev.sh"
bigbang_k3d_path=$(find "$initial_path" -type f -path "$relative_k3d_path")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find "$HOME/src/repo1/big-bang/bigbang" -type f -path "$relative_k3d_path")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find "$HOME/src" -type f -path "$relative_k3d_path")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find "$HOME/" -type f -path "$relative_k3d_path")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find "/home/" -type f -path "$relative_k3d_path")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find "/" -type f -path "$relative_k3d_path")
if [ ! -f "$bigbang_k3d_path" ]; then
	echo -e "error finding the k3d-dev script in the bigbang repo..." >&2
	exit 1
fi

bigbang_path="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(echo $bigbang_k3d_path)")")")")")"
if [ ! -d "$bigbang_path" ]; then
	echo -e "error finding the bigbang repo..." >&2
	exit 1
fi

echo "$bigbang_path"
