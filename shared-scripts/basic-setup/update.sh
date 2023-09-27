#! /usr/bin/env bash

#
# global defaults
#
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
		description: Updates basic-setup to the latest version.
		----------
		-h|--help      - (flag, default: false) Print this help message and exit.
		-v|--verbose   - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		update basic-setup - $command_for_help
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

old_dir="$(pwd)"
error_code=0
{
	basic_setup_dir="$(general-get-basic-setup-dir)"
	cd "$basic_setup_dir"
	if [ ! -z "$(git status --porcelain)" ]; then
		echo "Error checking for latest, git not porcelain at ${basic_setup_dir}. Please commit/stash your changes." >&2
		false
	else
		current_branch="$(git branch --show-current)"
		if [ "$current_branch" != "main" ]; then
			git checkout main
		fi
		git pull
	fi
} || {
	error_code=$?
}

cd "$old_dir"
if [ $error_code -ne 0 ]; then
	echo "Error: basic setup update failed." >&2
	exit $error_code
fi
