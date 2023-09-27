#! /usr/bin/env bash

# NOTE: don't run environment-validation here, it could cause a loop

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
		description: Returns the full path of the shared-scripts directory
		----------
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		get shared scripts dir - $command_for_help
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

shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="$(cd $(dirname ./shared-scripts) && pwd -P)/shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/.basic-setup -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find /home/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
	echo -e "error finding shared-scripts..." >&2
	exit 1
fi

echo "$shared_scripts_path"
