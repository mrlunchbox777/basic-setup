#! /usr/bin/env bash

#
# global defaults
#
ORIGINAL_ENV_FILE="${HOME}/.basic-setup/.env"
PASSED_GITHUB_ARG=false
PASSED_ALIAS_ARG=false
REQUIRE_ENV_FILE="${BASIC_SETUP_SHOULD_REQUIRE_ENV_FILE:-false}"
SHOULD_ADD_GITHUB_KEY=${BASIC_SETUP_SHOULD_ADD_GITHUB_KEY:-true}
SHOULD_DO_ALIAS_ONLY=${BASIC_SETUP_SHOULD_DO_ALIAS_ONLY:-false}
SHOW_HELP=false
SKIP_ENV="${BASIC_SETUP_SHOULD_SKIP_ENV_FILE:-false}"
VERBOSITY=0

#
# computed values (often can't be alphabetical)
#
if (( $(command -v general-get-source-and-dir >/dev/null 2>&1; echo $?) != 0 )); then
	echo "general-get-source-and-dir not found, please ensure \$basic_setup_directory/shared-scripts/bin is in your path before running..." >&2
	exit 1
fi
ENV_FILE="${BASIC_SETUP_ENV_FILE:-$ORIGINAL_ENV_FILE}"
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
		-e|--env-file - (string, default: "$ORIGINAL_ENV_FILE") The file to read environment variables from, will error if different from the default and not found, also set with \`BASIC_SETUP_ENV_FILE\`.
		-g|--github   - (flag, default: true) Add github.com to known_hosts (passing this sets it to false), also set with \`BASIC_SETUP_SHOULD_ADD_GITHUB_KEY\`.
		-h|--help     - (flag, default: false) Print this help message and exit.
		-r|--required - (flag, default: false) Exit if the environment file is missing (-s takes precedence), also set with \`BASIC_SETUP_SHOULD_REQUIRE_ENV_FILE\`.
		-s|--skip     - (flag, default: false) Skip the reading of the environment file (takes precedence over -r), also set with \`BASIC_SETUP_SHOULD_SKIP_ENV_FILE\`.
		-v|--verbose  - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		NOTE: -e, -r, and -s can only be set as environment variables or as arguments, not in the environment file.
		NOTE: processing order is: environment variables, environment file, arguments (last wins).
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
		PASSED_ALIAS_ARG=true
		shift
		;;
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
	# github flag
	-g | --github)
		SHOULD_ADD_GITHUB_KEY=false
		PASSED_GITHUB_ARG=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# required flag
	-r | --required)
		REQUIRE_ENV_FILE=true
		shift
		;;
	# skip flag
	-s | --skip)
		SKIP_ENV=true
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
	if [ "$ENV_FILE" != "$ORIGINAL_ENV_FILE" ] && [ ! -f "$ENV_FILE" ]; then
		echo "Error: Environment file not found at $ENV_FILE" >&2
		help
		exit 1
	fi
	if [ -f "$ENV_FILE" ]; then
		if [ "$PASSED_GITHUB_ARG" == "false" ]; then
			SHOULD_ADD_GITHUB_KEY=${BASIC_SETUP_SHOULD_ADD_GITHUB_KEY:-"$SHOULD_ADD_GITHUB_KEY"}
		fi
		if [ "$PASSED_ALIAS_ARG" == "false" ]; then
			SHOULD_DO_ALIAS_ONLY=${BASIC_SETUP_SHOULD_DO_ALIAS_ONLY:-"$SHOULD_DO_ALIAS_ONLY"}
		fi
		if [ "$ENV_FILE" != "$ORIGINAL_ENV_FILE" ]; then
			mkdir -p "${HOME}/.basic-setup"
			cp "$ENV_FILE" "$ORIGINAL_ENV_FILE"
		fi
		export $(cat $ORIGINAL_ENV_FILE | sed 's/#.*//g' | xargs)
	else if [ "$REQUIRE_ENV_FILE" == "true" ]; then
		echo "Error: Environment file required but not found at $ENV_FILE" >&2
		help
		exit 1
		fi
	fi
fi

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
general-send-message "init script complete, consider changing your shell 'chsh -s \"\$(which zsh)\"', you should probably restart your terminal and/or your computer"
