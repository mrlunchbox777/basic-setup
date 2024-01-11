#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -c -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
ARGS=""
SHOW_HELP=false
USE_INIT=true
USE_REMOTE=false
USE_RECURSIVE=true
VERBOSITY=${BASIC_SETUP_VERBOSITY:--1}

#
# load environment variables
#
. basic-setup-set-env

#
# computed values (often can't be alphabetical)
#
if (( $VERBOSITY == -1 )); then
	VERBOSITY=${BASIC_SETUP_VERBOSITY:-0}
fi


#
# helper functions
#

# script help message
function help {
	command_for_help="$(basename "$0")"
	local example_github_repo="https://github.com/mrlunchbox777/basic-setup"
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: Updates (and inits if needed) all submodules to the pinned version.
		----------
		-h|--help      - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--init      - (flag, current: $USE_INIT) Init submodules that have not been init-ed yet, pass -i to turn it off.
		-r|--remote    - (flag, current: $USE_REMOTE) Update to the remote instead of what the repo has pinned.
		-R|--recursive - (flag, current: $USE_RECURSIVE) Recursively update submodules, pass -R to turn it off.
		-v|--verbose   - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		update to pinned - $command_for_help
		update to latest - $command_for_help -r
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
	# init flag
	-i | --init)
		USE_INIT=false
		shift
		;;
	# remote flag
	-r | --remote)
		USE_REMOTE=true
		shift
		;;
	# recursive flag
	-R | --recursive)
		USE_RECURSIVE=false
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
[ $USE_INIT == true ] && ARGS+="--init "
[ $USE_REMOTE == true ] && ARGS+="--remote "
[ $USE_RECURSIVE == true ] && ARGS+="--recursive "

git submodule update $ARGS
