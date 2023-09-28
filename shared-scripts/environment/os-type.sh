#! /usr/bin/env bash

# NOTE: don't run environment-validation here, it could cause a loop

#
# global defaults
#
SHOW_HELP=false
TEST_CYGWIN=false
TEST_MINGW=false
TEST_LINUX=false
TEST_MAC=false
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
		description: Returns the OS type (Linux, Mac, Cygwin, MinGw)
		----------
		-c|--cygwin  - (flag, default: false) Test if the OS is Cygwin and exit, mutually exclusive test os flag.
		-g|--mingw   - (flag, default: false) Test if the OS is MinGw and exit, mutually exclusive test os flag.
		-h|--help    - (flag, default: false) Print this help message and exit.
		-l|--linux   - (flag, default: false) Test if the OS is Linux and exit, mutually exclusive test os flag.
		-m|--mac     - (flag, default: false) Test if the OS is Mac and exit, mutually exclusive test os flag.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		get os type          - $command_for_help
		check if os is linux - $command_for_help -l
		----------
	EOF
}

# get the test value for the operating system
function test_os {
	local actual_value="$1"
	local mutually_exclusive_count=0
	local expected_value=""
	[ "$TEST_CYGWIN" == "true" ] && ((mutually_exclusive_count+=1)) && expected_value="Cygwin"
	[ "$TEST_MINGW" == "true" ] && ((mutually_exclusive_count+=1)) && expected_value="MinGw"
	[ "$TEST_LINUX" == "true" ] && ((mutually_exclusive_count+=1)) && expected_value="Linux"
	[ "$TEST_MAC" == "true" ] && ((mutually_exclusive_count+=1)) && expected_value="Mac"
	if (( $mutually_exclusive_count > 1 )); then
		echo "All OS test flags are mutually exclusive" >&2
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
	# Cygwin flag
	-c | --cygwin)
		TEST_CYGWIN=true
		shift
		;;
	# MinGw flag
	-g | --mingw)
		TEST_MINGW=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# Linux flag
	-l | --linux)
		TEST_LINUX=true
		shift
		;;
	# Mac flag
	-m | --mac)
		TEST_MAC=true
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

machine=""
uname_out="$(uname -s)"
case "${uname_out}" in
	Linux*) machine="Linux" ;;
	Darwin*) machine="Mac"  ;;
	CYGWIN*) machine="Cygwin" ;;
	MINGW*) machine="MinGw" ;;
	*) machine="UNKNOWN:${uname_out}" ;;
esac

if [ "$TEST_CYGWIN" == "true" ] || [ "$TEST_MINGW" == "true" ] || [ "$TEST_LINUX" == "true" ] || [ "$TEST_MAC" == "true" ]; then
	test_os "$machine"
else
	echo "$machine"
fi

