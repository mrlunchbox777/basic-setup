#! /usr/bin/env bash

# Skip validation for this script

#
# global defaults
#
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

if [ ! -z "$(command -v basic-setup-set-env)" ]; then
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
		description: add basic-setup.gitconfig to ~/.gitconfig
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		add basic-setup.gitconfig - $command_for_help
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

if [ ! -f "$HOME/.gitconfig" ]; then
	touch "$HOME/.gitconfig"
fi

if [ -z "$(grep 'path = .*basic-setup.gitconfig"' ~/.gitconfig)" ]; then
	dir="$(general-get-basic-setup-dir)"
	target_dir=$(readlink -f "$dir/basic-setup.gitconfig")
	echo -e "\n[include]\n  path = \"$target_dir\"" >> ~/.gitconfig
else
	echo "Update redundant. Skipping update for .gitconfig..."
fi
