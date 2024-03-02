#! /usr/bin/env bash

#
# global defaults
#
SHOW_HELP=false
# TODO: allow this to be changed
ORIGINAL_ENV_FILE="${HOME}/.basic-setup/.env"
SHOULD_ADD_GITHUB_KEY=${BASIC_SETUP_BASIC_SETUP_INIT_SHOULD_ADD_GITHUB_KEY:-""}
SHOULD_DO_ALIAS_ONLY=${BASIC_SETUP_BASIC_SETUP_INIT_SHOULD_DO_ALIAS_ONLY:-""}
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if (( $(command -v general-get-source-and-dir >/dev/null 2>&1; echo $?) != 0 )); then
	echo "general-get-source-and-dir not found, please ensure \$basic_setup_directory/shared-scripts/bin is in your path before running..." >&2
	exit 1
fi
if [ -z "$SHOULD_ADD_GITHUB_KEY" ]; then
	SHOULD_ADD_GITHUB_KEY=${BASIC_SETUP_BASIC_SETUP_INIT_SHOULD_ADD_GITHUB_KEY:-true}
fi
if [ -z "$SHOULD_DO_ALIAS_ONLY" ]; then
	SHOULD_DO_ALIAS_ONLY=${BASIC_SETUP_BASIC_SETUP_INIT_SHOULD_DO_ALIAS_ONLY:-false}
fi
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi
INITIAL_DIR="$(pwd)"
SOURCE="${BASH_SOURCE[0]}"
SD="$(general-get-source-and-dir -s "$SOURCE")"
SOURCE="$(echo "$SD" | jq -r .source)"
DIR="$(echo "$SD" | jq -r .dir)"

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
		description: 
		----------
		-a|--alias   - (flag, current: $SHOULD_DO_ALIAS_ONLY) Only add aliases, also set with \`BASIC_SETUP_BASIC_SETUP_INIT_SHOULD_DO_ALIAS_ONLY\`.
		-g|--github  - (flag, current: $SHOULD_ADD_GITHUB_KEY) Add github.com to known_hosts (passing this sets it to false), also set with \`BASIC_SETUP_BASIC_SETUP_INIT_SHOULD_ADD_GITHUB_KEY\`.
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: variable processing order is: environment file, environment variables, arguments (last wins).
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
	# alias only flag
	-a | --alias)
		SHOULD_DO_ALIAS_ONLY=true
		shift
		;;
	# github flag
	-g | --github)
		SHOULD_ADD_GITHUB_KEY=false
		shift
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

# track directories
cd "$DIR"

if [ "$SHOULD_ADD_GITHUB_KEY" == "true" ]; then
	ssh-keyscan -t rsa github.com | ssh-keygen -lf -
fi

git-submodule-update-all
if [ "$SHOULD_DO_ALIAS_ONLY" == "false" ]; then
	environment-validation -i -c -v
fi
git-add-basic-setup-gitconfig
basic-setup-add-general-rc

# move back to original dir and update user
cd "$INITIAL_DIR"
general-send-message -m "init script complete, consider changing your shell 'chsh -s \"\$(which zsh)\"', you should probably restart your terminal and/or your computer"
