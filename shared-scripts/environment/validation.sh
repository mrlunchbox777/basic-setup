#! /usr/bin/env bash

set_e_after=0
if [[ $- =~ e ]]; then
	set_e_after=1
else
	set -e
fi

update_e() {
	if (( set_e_after == 0 )); then
		set +e
	fi
}

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
		description: This script will validate that everything that is needed is included in your environment.
		----------
		-f|--force   - (flag, default: false) Force the validation (don't skip if previously passed).
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: This script will error out if the environment is misconfigured. It should also tell you what can be done to correct the issue.
		----------
		examples:
		validate environment - $command_for_help
		----------
	EOF
}

force=0
while getopts ":fhv" opt; do
	case "$opt" in
		f) force=1 ;;
		h) help; exit 0 ;;
		v) echo "not implemented"; exit 0 ;;
		*) help; exit 1 ;;
	esac
done
basic_setup_directory="$HOME/.basic-setup/"
previously_validated_file_name=".environment_validated_by_environment-validation"
mkdir -p $basic_setup_directory

skip=0
if (( "$force" == 0 )) && [ "$(find "$basic_setup_directory" -maxdepth 1 -name $previously_validated_file_name -mmin -1440)" ]; then
	skip=1
	# TODO: add verbose and push this out
	# echo "previously validated - skipping" 1>&2
fi

# TODO: add a check for on main at latest, and an env var to skip that check (and notes in help to fix/skip that)

uname_out="$(uname -s)"
case "${uname_out}" in
	Linux*) machine="Linux" && package_manager_name="apt" ;;
	Darwin*) machine="Mac" && package_manager_name="brew" ;;
	CYGWIN*) machine="Cygwin" && package_manager_name="manually" ;;
	MINGW*) machine="MinGw" && package_manager_name="manually" ;;
	*) machine="UNKNOWN:${uname_out}" && package_manager_name="manually"
esac
error_messages=()

packages=$(cat "$(general-get-basic-setup-dir)/install/index.json")

function is_command_installed() {
	local command_name=$1
	echo "$(command -v "$command_name" 2>&1 > /dev/null; echo $?)"
}

function check_for_jq() {
	local is_jq_installed=$(is_command_installed "jq")
	if (( $is_jq_installed == 0 )); then
		# TODO maybe install it instead
		echo "\`jq\` must be installed to get a list of to be installed packages. Please follow these instructions - https://stedolan.github.io/jq/download/"
		usage
		exit 1
	fi
}
