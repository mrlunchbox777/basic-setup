#! /usr/bin/env bash

#
# global defaults
#
GITHUB_REPO=false
RELEASES=false
REPO_PATH=""
SHOW_HELP=false
TAGS=false
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
		-g|--github repo - (required) The frontend url of the github repo, e.g. '${example_github_repo}'.
		-h|--help        - (flag, default: false) Print this help message and exit.
		-r|--releases    - (flag, default: false) Get the release versions, mutually exclusive with -t.
		-t|--tags     - (flag, default: false) Get the tag versions, mutually exclusive with -r.
		-v|--verbose  - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: -r or -t must be specified
		----------
		examples:
		get release versions - $command_for_help -r -g "${example_github_repo}"
		get tag versions     - $command_for_help -t -g "${example_github_repo}"
		----------
	EOF
}

# TODO: WIP - get the latest version from github
# get the versions from github
function get_versions {
	local should_continue=true
	local page=1
	local all_versions=""
	local name_kind="name"
	[ "$VERSION_KIND" == "releases" ] && local name_kind="tag_name"
	# TODO: support throttling (this needs to be added to the other curl commands as well - https://docs.github.com/en/rest/overview/resources-in-the-rest-api?apiVersion=2022-11-28#rate-limiting)
	while [ "$should_continue" == true ]; do
		local current_versions="$(curl -s "https://api.github.com/repos/${REPO_PATH}/${VERSION_KIND}?page=$page&per_page=100" | jq '[.[] | ."'${name_kind}'"]')"
		if (( $(echo "$current_versions" | jq length) == 0 )); then
			local should_continue=false
		fi
		local all_versions="$(echo "${all_versions}${current_versions}" | jq -s add)"
		local page=$(($page+1))
	done
	echo "$all_versions" | jq -r '.[]'
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
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
[ "$RELEASES" == true ] && [ "$TAGS" == true ] && echo "Error: -r and -t are mutually exclusive" >&2 && help && exit 1
[ "$TAGS" == true ] && VERSION_KIND="tags"
[ "$RELEASES" == true ] && VERSION_KIND="releases"
[ "$GITHUB_REPO" == false ] && echo "Error: -g is required" >&2 && help && exit 1
[ "$VERSION_KIND" == "" ] && echo "Error: -r or -t is required" >&2 && help && exit 1
REPO_PATH="$(echo "$GITHUB_REPO" | sed 's#http[s]*://github.com/##g; s#/$##g')"

get_versions
