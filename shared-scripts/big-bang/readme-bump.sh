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
VERBOSITY=0

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
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: Adapted from and for more info see - https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md
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
