#! /usr/bin/env bash

#
# global defaults
#
SHOW_HELP=false
VERBOSITY=0
REQUIRE_ENV_FILE="${BASIC_SETUP_SHOULD_REQUIRE_ENV_FILE:-false}"
RC_FILES="${BASIC_SETUP_RC_FILES:-".bashrc, .zshrc, .profile, .zprofile"}"

#
# computed values (often can't be alphabetical)
#
BASIC_SETUP_DIR=$(general-get-basic-setup-dir)
IFS=", " read -r -a RC_FILES_ARRAY <<< "$RC_FILES"

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
		description: adds basic-setup's general-rc to the following files in \`$HOME\`: ${RC_FILES_ARRAY[@]}.
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

for rc_file in "${RC_FILES_ARRAY[@]}"; do
	update_rc "$rc_file"
done
