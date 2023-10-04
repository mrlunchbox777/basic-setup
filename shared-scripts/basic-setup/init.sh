#! /usr/bin/env bash

#
# global defaults
#
SHOW_HELP=false
VERBOSITY=0
ORIGINAL_ENV_FILE="${HOME}/.env"
ENV_FILE="$ORIGINAL_ENV_FILE"

#
# computed values (often can't be alphabetical)
#
INITIAL_DIR="$(pwd)"
SOURCE="${BASH_SOURCE[0]}"
SD="$(general-get-source-and-dir "$SOURCE")"
SOURCE="$(echo "$sd" | jq -r .source)"
DIR="$(echo "$sd" | jq -r .dir)"
SKIP_ENV="${BASIC_SETUP_SHOULD_SKIP_ENV_FILE:-false}"

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
		-e|--env-file - (string, default: "$ENV_FILE") The file to read environment variables from, will error if different from the default and not found.
		-h|--help     - (flag, default: false) Print this help message and exit.
		-s|--skip     - (flag, default: false) Skip the reading of the environment file, also set with \`BASIC_SETUP_SHOULD_SKIP_ENV_FILE\`.
		-v|--verbose  - (multi-flag, default: 0) Increase the verbosity by 1.
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
	# env-file flag
	-e | --env-file)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			ENV_FILE="$2"
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

# load environment variables
if [ "$SKIP_ENV" == "false" ]; then
	if [ ! -f "$ENV_FILE" ]; then
		echo "Error: Environment file not found at $ENV_FILE" >&2
		help
		exit 1
	fi
fi
if [ -f "$ENV_FILE" ]; then
	export $(cat $ENV_FILE | sed 's/#.*//g' | xargs)
fi

if (( $(command -v general-get-source-and-dir >/dev/null 2>&1; echo $?) != 0 )); then
	echo "general-get-source-and-dir not found, please ensure \$basic_setup_directory/shared-scripts/bin is in your path before running..." >&2
	exit 1
fi

# track directories
cd "$DIR"

# Set variables
## General variables
should_do_alias_only=${BASIC_SETUP_SHOULD_DO_ALIAS_ONLY:-false}
should_add_github_key=${BASIC_SETUP_SHOULD_ADD_GITHUB_KEY:-"true"}

if [ "$should_add_github_key" == "true" ]; then
	ssh-keyscan -t rsa github.com | ssh-keygen -lf -
fi

git-submodule-update-all
environment-validation -i -c -v
git-add-basic-setup-gitconfig
basic-setup-add-general-rc

# move back to original dir and update user
cd "$INITIAL_DIR"
general-send-message "init script complete, consider changing your shell 'chsh -s \"\$(which zsh)\"', you should probably restart your terminal and/or your computer"
