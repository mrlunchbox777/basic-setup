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
		note: Adapted from and for more info see - https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md
		note: everything under big-bang will be moved to https://repo1.dso.mil/big-bang/product/packages/bbctl eventually
		----------
		examples:
		update the readme - $command_for_help
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

curl -LO https://repo1.dso.mil/big-bang/apps/library-charts/gluon/-/raw/master/docs/README.md.gotmpl
curl -LO https://repo1.dso.mil/big-bang/apps/library-charts/gluon/-/raw/master/docs/.helmdocsignore
curl -LO https://repo1.dso.mil/big-bang/apps/library-charts/gluon/-/raw/master/docs/_templates.gotmpl
docker run --rm -v "$(pwd):/helm-docs" -u $(id -u) jnorwood/helm-docs:v1.10.0 -s file -t /helm-docs/README.md.gotmpl -t /helm-docs/_templates.gotmpl --dry-run > README.md
rm .helmdocsignore README.md.gotmpl _templates.gotmpl
