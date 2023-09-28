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
SHOW_HELP=false
VERBOSITY=0

#
# helper functions
#

# script help message
function help {
	command_for_help="$(basename "$0")"
	# TODO: add ability to specify helm registry creds
	# TODO: add ability to specify git repo creds
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: updates the readme for the bigbang helm chart
		----------
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		upsert basic big bang overrides - $command_for_help
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

basic_setup_dir="$(general-get-basic-setup-dir)"
big_bang_dir="$(big-bang-get-repo-dir)"

if [ ! -d "$big_bang_dir" ]; then
	echo "Error: big bang repo not found at $big_bang_dir" >&2
	exit 1
fi

override_dir="$big_bang_dir/../overrides"

if [ ! -d "$override_dir" ]; then
	mkdir -p "$override_dir"
fi

# TODO: handle if repo/registry creds exist and if they are passed in
cp -f $basic_setup_dir/resources/big-bang-overrides/* "$override_dir/"
