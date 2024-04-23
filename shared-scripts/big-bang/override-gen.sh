#! /usr/bin/env bash

#
# Environment Validation
#
validation="$(environment-validation -l "big-bang" -l "core" 2>&1)"
if [ ! -z "$validation" ]; then
	echo "Validation error:" >&2
	echo "$validation" >&2
	exit 1
fi

#
# global defaults
#
HAD_REGISTRY_CREDS=false
HAD_REPO_CREDS=false
SHOW_HELP=false
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
	cat <<- EOF
		----------
		usage: $command_for_help <arguments>
		----------
		description: updates the readme for the bigbang helm chart
		----------
		-h|--help    - (flag, current: $SHOW_HELP) Print this help message and exit.
		-v|--verbose - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
		----------
		examples:
		upsert basic big bang overrides - $command_for_help
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

basic_setup_dir="$(general-get-basic-setup-dir)"
big_bang_dir="$(big-bang-get-repo-dir)"

if [ ! -d "$big_bang_dir" ]; then
	echo "Error: big bang repo not found at $big_bang_dir" >&2
	exit 1
fi

override_dir="$big_bang_dir/../overrides"

if [ ! -d "$override_dir" ]; then
	mkdir -p "$override_dir"
fi

if [ -f "$override_dir/registry-values.yaml" ]; then
	(($VERBOSITY > 0)) && echo "Backing up registry-values.yaml" >&2
	cp -f "$override_dir/registry-values.yaml" "$override_dir/registry-values.yaml.bak"
	HAD_REGISTRY_CREDS=true
fi

if [ -f "$override_dir/repo-values.yaml" ]; then
	(($VERBOSITY > 0)) && echo "Backing up repo-values.yaml" >&2
	cp -f "$override_dir/repo-values.yaml" "$override_dir/repo-values.yaml.bak"
	HAD_REPO_CREDS=true
fi

cp -f $basic_setup_dir/resources/big-bang-overrides/* "$override_dir/"

if [ "$HAD_REGISTRY_CREDS" == true ]; then
	(($VERBOSITY > 0)) && echo "Restoring registry-values.yaml" >&2
	cp -f "$override_dir/registry-values.yaml.bak" "$override_dir/registry-values.yaml"
else
	(($VERBOSITY > 0)) && echo "Update $override_dir/registry-values.yaml" >&2
fi

if [ "$HAD_REPO_CREDS" == true ]; then
	(($VERBOSITY > 0)) && echo "Restoring repo-values.yaml" >&2
	cp -f "$override_dir/repo-values.yaml.bak" "$override_dir/repo-values.yaml"
else
	(($VERBOSITY > 0)) && echo "Update $override_dir/repo-values.yaml" >&2
fi

exit 0
