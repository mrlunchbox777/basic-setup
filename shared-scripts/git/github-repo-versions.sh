#! /usr/bin/env bash

#
# global defaults
#
CACHE_BASE_DIR="$HOME/.cache/github-repo-versions"
GITHUB_REPO=false
RELEASES=false
REPO_PATH=""
SHOW_HELP=false
TAGS=false
USE_CURL=false
VERBOSITY=0
VERSION_KIND=""

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
		description: Returns the OS type (Linux, Mac, Cygwin, MinGw)
		----------
		-c|--curl        - (optional, default: false) use github api instead of a local "clone -n" to get metadata, can cause rate limiting'.
		-g|--github-repo - (required) The frontend url of the github repo, e.g. '${example_github_repo}'.
		-h|--help        - (flag, default: false) Print this help message and exit.
		-r|--releases    - (flag, default: false) Get the release versions, mutually exclusive with -t (one is required), requires -c.
		-t|--tags        - (flag, default: false) Get the tag versions, mutually exclusive with -r (one is required).
		-v|--verbose     - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: -r or -t must be specified
		----------
		examples:
		get release versions - $command_for_help -r -g "${example_github_repo}"
		get tag versions     - $command_for_help -t -g "${example_github_repo}"
		----------
	EOF
}

# get the versions from github
get_versions_curl() {
	local should_continue=true
	local page=1
	local all_versions=""
	local name_kind="name"
	[ "$VERSION_KIND" == "releases" ] && local name_kind="tag_name"
	while [ "$should_continue" == true ]; do
		local curl_url="https://api.github.com/repos/${REPO_PATH}/${VERSION_KIND}?page=$page&per_page=100"
		local raw_content="$(curl -s "$curl_url")"
		if [[ "$raw_content" == *"API rate limit exceeded"* ]]; then
			echo "Error: API rate limit exceeded" 1>&2
			echo "Error: run 'curl -s -v \"$curl_url\"' for more info." 1>&2
			local seconds="$(curl -s -v "$curl_url" 2>&1 | grep 'x-ratelimit-reset' | awk '{print $3}' | sed 's/[^0-9]*//g' )"
			echo "Error: Github rate limit resets at $(date -d @"$seconds")." 1>&2
			exit 1
		fi
		local current_versions="$(echo "$raw_content" | jq '[.[] | ."'${name_kind}'"]')"
		if (( $(echo "$current_versions" | jq length) == 0 )); then
			local should_continue=false
		fi
		local all_versions="$(echo "${all_versions}${current_versions}" | jq -s add)"
		local page=$(($page+1))
	done
	echo "$all_versions" | jq -r '.[]'
}

# get the versions from local git repo
get_versions_local() {
	if [ ! -d "$CACHE_BASE_DIR" ]; then
		mkdir -p "$CACHE_BASE_DIR"
	fi
	# clone the repo if it doesn't exist
	if [ ! -d "${CACHE_BASE_DIR}/${REPO_PATH}" ]; then
		git clone -n "$GITHUB_REPO.git" "${CACHE_BASE_DIR}/${REPO_PATH}"
	fi
	local old_dir="$(pwd)"
	local error_code=0
	cd "${CACHE_BASE_DIR}/${REPO_PATH}"
	{
		git fetch -p -t
		git tag --list
	} || {
		local error_code=$?
	}
	cd $old_dir
	if [ "$error_code" != 0 ]; then
		echo "Error: git clone failed: $error_code" 1>&2
		help
		exit $error_code
	fi
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# curl flag
	-c | --curl)
		USE_CURL=true
		shift
		;;
	# the github repo, required argument
	-g | --github-repo)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			GITHUB_REPO="$2"
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
	# Releases flag
	-r | --releases)
		RELEASES=true
		shift
		;;
	# Tags flag
	-t | --tags)
		TAGS=true
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
[ "$RELEASES" == false ] && [ "$TAGS" == false ] && echo "Error: one of -r and -t are required" >&2 && help && exit 1
[ "$RELEASES" == true ] && [ "$TAGS" == true ] && echo "Error: -r and -t are mutually exclusive" >&2 && help && exit 1
[ "$RELEASES" == true ] && [ "$USE_CURL" == false ] && echo "Error: -r requires -c" >&2 && help && exit 1
[ "$TAGS" == true ] && VERSION_KIND="tags"
[ "$RELEASES" == true ] && VERSION_KIND="releases"
[ "$GITHUB_REPO" == false ] && echo "Error: -g is required" >&2 && help && exit 1
[ "$VERSION_KIND" == "" ] && echo "Error: -r or -t is required" >&2 && help && exit 1
REPO_PATH="$(echo "$GITHUB_REPO" | sed 's#http[s]*://github.com/##g; s#/$##g')"

if [ "$USE_CURL" == true ]; then
	get_versions_curl
else
	get_versions_local
fi
