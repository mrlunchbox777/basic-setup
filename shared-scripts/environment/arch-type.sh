#! /usr/bin/env bash

#
# global defaults
#
SHOW_HELP=false
TEST_ARM=false
TEST_X64=false
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
		description: Returns the architecture type (only x64, and arm64 supported right now)
		----------
		-a|--arm64   - (flag, default: false) Test if the architecture is arm64 compatible and exit, mutually exclusive test arch flag.
		-h|--help    - (flag, default: false) Print this help message and exit.
		-x|--x64     - (flag, default: false) Test if the architecture is x86_64 compatible and exit, mutually exclusive test arch flag.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		get arch type          - $command_for_help
		check if arch is arm64 - $command_for_help -a
		----------
	EOF
}

# get the test value for the architecture system
function test_arch {
	local actual_value="$1"
	local mutually_exclusive_count=0
	local expected_value=""
	[ "$TEST_ARM" == "true" ] && ((mutually_exclusive_count+=1)) && expected_value="arm64"
	[ "$TEST_X64" == "true" ] && ((mutually_exclusive_count+=1)) && expected_value="x64"
	if (( $mutually_exclusive_count > 1 )); then
		echo "All arch test flags are mutually exclusive" >&2
		help
		exit 1
	fi
	[ "$actual_value" == "$expected_value" ] && echo true || echo false
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# ARM flag
	-a | --arm64)
		TEST_ARM=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# ix86_64 flag
	-x | --x64)
		TEST_X64=true
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

arch=""
uname_out="$(uname -m)"
case "${uname_out}" in
	aarch64*) arch="arm64" ;;
	armv8b*) arch="arm64"  ;;
	armv8l*) arch="arm64" ;;
	x86_64*) arch="x64" ;;
	*) arch="UNKNOWN:${uname_out}" ;;
esac

if [ "$TEST_ARM" == "true" ] || [ "$TEST_X64" == "true" ]; then
	test_arch "$arch"
else
	echo "$arch"
fi


