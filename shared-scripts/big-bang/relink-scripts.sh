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
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: cleans the shared-scripts/big-bang/bin directory and then relinks the scripts from big bang
		----------
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		recreate the bigbang script links - $command_for_help
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

bigbang_path="$(big-bang-get-repo-dir)"
shared_scripts_path="$(general-get-shared-scripts-dir)"
bigbang_link_dir="$shared_scripts_path/big-bang/bin"

# remove the bigbang links
rm -f "$bigbang_link_dir"/*

# link the bigbang scripts
touch "$bigbang_link_dir/.gitkeep"
for script in $(find "$bigbang_path" -type f -name "*.sh"); do
	script_name="$(basename "$script")"
	ln -s "$script" "$bigbang_link_dir/bb-$script_name"
done

