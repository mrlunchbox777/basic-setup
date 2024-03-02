#! /usr/bin/env bash

# skip environment validation to prevent loops

#
# global defaults
#
GITHUB_REPO=false
RELEASES=false
REPO_PATH=""
SEMANTIC_PREFIX=""
SEMANTIC_VERSIONING=false
SHOW_HELP=false
TAGS=false
USE_CURL=false
VERSION_KIND=""
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
		description: Returns the OS type (Linux, Mac, Cygwin, MinGw)
		----------
		-c|--curl            - (flag, current: $USE_CURL) use github api instead of a local "clone -n" to get metadata, can cause rate limiting'.
		-g|--github-repo     - (required, current: "$GITHUB_REPO") The frontend url of the github repo, e.g. '${example_github_repo}'.
		-h|--help            - (flag, current: $SHOW_HELP) Print this help message and exit.
		-r|--releases        - (flag, current: $RELEASES) Get the release versions, mutually exclusive with -t (one is required), requires -c.
		-p|--semantic-prefix - (flag, current: "$SEMANTIC_PREFIX") The tag prefix for the sematic versioning, requires no -c.
		-s|--semantic        - (flag, current: $SEMANTIC_VERSIONING) sort and filter with semantic versioning, requires no -c.
		-t|--tags            - (flag, current: $TAGS) Get the tag versions, mutually exclusive with -r (one is required).
		-v|--verbose         - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
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
	all_tags=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' "$GITHUB_REPO" | awk '{print $2}' | sed 's#refs/tags/##g')
	if [ "$SEMANTIC_VERSIONING" == true ]; then
		all_tags="$(echo "$all_tags" | grep '^'$SEMANTIC_PREFIX'[0-9]*\.[0-9]*\.[0-9]*[-.*]*$')"
	fi
	echo $all_tags | sed 's/ /\n/g' | sort -Vr
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
	# The semantic prefix, optional argument
	-p | --semantic-prefix)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			SEMANTIC_PREFIX="$2"
			shift 2
		else
			SEMANTIC_PREFIX=""
			shift 1
		fi
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
	# Semantic flag
	-s | --semantic)
		SEMANTIC_VERSIONING=true
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
[ "$SEMANTIC_VERSIONING" == true ] && [ "$USE_CURL" == true ] && echo "Error: -s requires no -c" >&2 && help && exit 1
[ ! -z "$SEMANTIC_PREFIX" ] && [ "$USE_CURL" == true ] && echo "Error: -p no -c" >&2 && help && exit 1
REPO_PATH="$(echo "$GITHUB_REPO" | sed 's#http[s]*://github.com/##g; s#/$##g')"

if [ "$USE_CURL" == true ]; then
	get_versions_curl
else
	get_versions_local
fi
