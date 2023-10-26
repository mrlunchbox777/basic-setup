#! /usr/bin/env bash

#
# global defaults
#
RC_FILES=$BASIC_SETUP_RC_FILES
SHOW_HELP=false
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if [ -z "$RC_FILES" ]; then
	RC_FILES="${BASIC_SETUP_RC_FILES:-".bashrc, .zshrc, .profile, .zprofile"}"
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
BASIC_SETUP_DIR=$(general-get-basic-setup-dir)

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
		description: adds basic-setup's general-rc to the following files in \`$HOME\`: $RC_FILES.
		----------
		-h|--help     - (flag, current: $SHOW_HELP) Print this help message and exit.
		-r|--rc-files - (current: $RC_FILES) The rc files to add the general-rc to, also set with \`BASIC_SETUP_RC_FILES\`.
		-v|--verbose  - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
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
	# rc-files, optional argument
	-r | --rc-files)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			RC_FILES=$2
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
IFS=", " read -r -a rc_files_array <<< "$RC_FILES"
[ $SHOW_HELP == true ] && help && exit 0

function update_rc {
	local rc_file="$1"

	if [ ! -f "$HOME/$rc_file" ]; then
		touch "$HOME/$rc_file"
	fi

	if (($(grep '^\. .*alias/basic-setup.generalrc.sh"$' $HOME/$rc_file >/dev/null 2>&1; echo $?) != 0)); then
		local target_dir=$(readlink -f "$BASIC_SETUP_DIR/alias/basic-setup.generalrc.sh")
		echo -e "\n. \"$target_dir\"" >> ~/$rc_file
	else
		echo "Update redundant. Skipping update for $rc_file..."
	fi
}

for rc_file in "${rc_files_array[@]}"; do
	update_rc "$rc_file"
done
