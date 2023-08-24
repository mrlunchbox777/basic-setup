#! /usr/bin/env bash

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
		description: Returnsthe full path of the the bigbang directory
		----------
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		get basic setup dir - $command_for_help
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

bigbang_k3d_path=$(find ./ -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find $HOME/src -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find $HOME/ -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find /home/ -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
[ ! -f "$bigbang_k3d_path" ] && bigbang_k3d_path=$(find / -type f -path "*/docs/assets/scripts/developer/k3d-dev.sh")
if [ ! -f "$bigbang_k3d_path" ]; then
	echo -e "error finding the k3d-dev script in the bigbang repo..." >&2
	exit 1
fi

bigbang_path="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$(echo $bigbang_k3d_path)")")")")")"
if [ ! -d "$bigbang_path" ]; then
	echo -e "error finding the bigbang repo..." >&2
	exit 1
fi

echo "$bigbang_path"
