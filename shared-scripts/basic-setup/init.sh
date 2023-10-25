#! /usr/bin/env bash

#
# global defaults
#
ORIGINAL_ENV_FILE="${HOME}/.basic-setup/.env"
BASIC_SETUP_SHOULD_ADD_GITHUB_KEY=${BASIC_SETUP_SHOULD_ADD_GITHUB_KEY:-true}
BASIC_SETUP_SHOULD_DO_ALIAS_ONLY=${BASIC_SETUP_SHOULD_DO_ALIAS_ONLY:-false}
SHOW_HELP=false
SKIP_ENV="${BASIC_SETUP_SHOULD_SKIP_ENV_FILE:-false}"
VERBOSITY=0

# load environment variables
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if (( $(command -v general-get-source-and-dir >/dev/null 2>&1; echo $?) != 0 )); then
	echo "general-get-source-and-dir not found, please ensure \$basic_setup_directory/shared-scripts/bin is in your path before running..." >&2
	exit 1
fi
INITIAL_DIR="$(pwd)"
SOURCE="${BASH_SOURCE[0]}"
SD="$(general-get-source-and-dir "$SOURCE")"
SOURCE="$(echo "$sd" | jq -r .source)"
DIR="$(echo "$sd" | jq -r .dir)"

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
		-a|--alias    - (flag, default: false) Only add aliases, also set with \`BASIC_SETUP_SHOULD_DO_ALIAS_ONLY\`.
		-g|--github   - (flag, default: true) Add github.com to known_hosts (passing this sets it to false), also set with \`BASIC_SETUP_SHOULD_ADD_GITHUB_KEY\`.
		-h|--help     - (flag, default: false) Print this help message and exit.
		-v|--verbose  - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		NOTE: variable processing order is: environment variables, environment file, arguments (last wins).
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
		BASIC_SETUP_SHOULD_DO_ALIAS_ONLY=true
		shift
		;;
	# github flag
	-g | --github)
		BASIC_SETUP_SHOULD_ADD_GITHUB_KEY=false
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

if [ "$BASIC_SETUP_SHOULD_ADD_GITHUB_KEY" == "true" ]; then
	ssh-keyscan -t rsa github.com | ssh-keygen -lf -
fi

git-submodule-update-all
if [ "$BASIC_SETUP_SHOULD_DO_ALIAS_ONLY" == "false" ]; then
	environment-validation -i -c -v
fi
git-add-basic-setup-gitconfig
basic-setup-add-general-rc

# move back to original dir and update user
cd "$INITIAL_DIR"
general-send-message "init script complete, consider changing your shell 'chsh -s \"\$(which zsh)\"', you should probably restart your terminal and/or your computer"
