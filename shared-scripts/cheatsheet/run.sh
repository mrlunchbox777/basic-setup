#! /usr/bin/env bash
#
# Environment Validation
#
# skipping environment validation because this script doesn't require any other packages

#
# global defaults
#
# The majority of these don't support environment variables because they are intended to be flags
CHEATSHEETS_TO_SHOW=()
SHOW_ALIAS=false
SHOW_ALL=false
SHOW_BASE=false
SHOW_COMPILATION=false
SHOW_DOCKER=false
SHOW_GENERAL=false
SHOW_HELP=false
SHOW_INDEX=false
SHOW_KUBERNETES=false
SHOW_METRICS=false
SHOW_NETWORKING=false
SHOW_PROCESS_MANIPULATION=false
SHOW_SYSTEM=false
SHOW_TEXT_MANIPULATION=false
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
BASIC_SETUP_DIR=$(general-get-basic-setup-dir)

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
		description: pretty prints cheatsheets to the terminal
		----------
		-a|--alias                - (flag, current: $SHOW_ALIAS) Include alias.md.
		--all                     - (flag, current: $SHOW_ALL) Show all cheatsheets, takes precendence.
		-b|--base                 - (flag, current: $SHOW_BASE) Include base.md.
		-c|--compilation          - (flag, current: $SHOW_COMPILATION) Include compilation.md.
		-d|--docker               - (flag, current: $SHOW_DOCKER) Include docker.md.
		-g|--general              - (flag, current: $SHOW_GENERAL) Include general.md.
		-h|--help                 - (flag, current: $SHOW_HELP) Print this help message and exit.
		-i|--index                - (flag, current: $SHOW_INDEX) Include index.md.
		-k|--kubernetes           - (flag, current: $SHOW_KUBERNETES) Include kubernetes.md.
		-m|--metrics              - (flag, current: $SHOW_METRICS) Include metrics.md.
		-n|--networking           - (flag, current: $SHOW_NETWORKING) Include networking.md.
		-p|--process-manipulation - (flag, current: $SHOW_PROCESS_MANIPULATION) Include process-manipulation.md.
		-s|--system               - (flag, current: $SHOW_SYSTEM) Include system.md.
		-t|--text-manipulation    - (flag, current: $SHOW_TEXT_MANIPULATION) Include text-manipulation.md.
		-v|--verbose              - (multi-flag, current: $VERBOSITY) Increase the verbosity by 1, also set with \`BASIC_SETUP_VERBOSITY\`.
		----------
		examples:
		print cheatsheet index - $command_for_help -i
		print all cheatsheets  - $command_for_help --all
		----------
	EOF
}

# find and cat a cheatsheet
write-a-cheatsheet() {
	if [ -z "$1" ]; then
		echo "no cheatsheet name provided"
		return 1
	fi
	cheatsheet_file="$BASIC_SETUP_DIR/resources/cheatsheet-docs/$1"
	if [ ! -f "$cheatsheet_file" ]; then
		echo "cheatsheet file not found: $cheatsheet_file"
		return 1
	fi
	cat "$cheatsheet_file"
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# show alias
	-a | --alias)
		SHOW_ALIAS=true
		shift
		;;
	# show all flag
	--all)
		SHOW_ALL=true
		shift
		;;
	# show base
	-b | --base)
		SHOW_BASE=true
		shift
		;;
	# show compilation
	-c | --compilation)
		SHOW_COMPILATION=true
		shift
		;;
	# show docker
	-d | --docker)
		SHOW_DOCKER=true
		shift
		;;
	# show general
	-g | --general)
		SHOW_GENERAL=true
		shift
		;;
	# help flag
	-h | --help)
		SHOW_HELP=true
		shift
		;;
	# index flag
	-i | --index)
		SHOW_INDEX=true
		shift
		;;
	# kubernetes flag
	-k | --kubernetes)
		SHOW_KUBERNETES=true
		shift
		;;
	# metrics flag
	-m | --metrics)
		SHOW_METRICS=true
		shift
		;;
	# networking flag
	-n | --networking)
		SHOW_NETWORKING=true
		shift
		;;
	# process-manipulation flag
	-p | --process-manipulation)
		SHOW_PROCESS_MANIPULATION=true
		shift
		;;
	# system flag
	-s | --system)
		SHOW_SYSTEM=true
		shift
		;;
	# text-manipulation flag
	-t | --text-manipulation)
		SHOW_TEXT_MANIPULATION=true
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
if [ "$SHOW_ALIAS" == true ]; then
	CHEATSHEETS_TO_SHOW+=("alias.md")
fi
if [ "$SHOW_BASE" == true ]; then
	CHEATSHEETS_TO_SHOW+=("base.md")
fi
if [ "$SHOW_COMPILATION" == true ]; then
	CHEATSHEETS_TO_SHOW+=("compilation.md")
fi
if [ "$SHOW_DOCKER" == true ]; then
	CHEATSHEETS_TO_SHOW+=("docker.md")
fi
if [ "$SHOW_GENERAL" == true ]; then
	CHEATSHEETS_TO_SHOW+=("general.md")
fi
if [ "$SHOW_INDEX" == true ]; then
	CHEATSHEETS_TO_SHOW+=("index.md")
fi
if [ "$SHOW_KUBERNETES" == true ]; then
	CHEATSHEETS_TO_SHOW+=("kubernetes.md")
fi
if [ "$SHOW_METRICS" == true ]; then
	CHEATSHEETS_TO_SHOW+=("metrics.md")
fi
if [ "$SHOW_NETWORKING" == true ]; then
	CHEATSHEETS_TO_SHOW+=("networking.md")
fi
if [ "$SHOW_PROCESS_MANIPULATION" == true ]; then
	CHEATSHEETS_TO_SHOW+=("process-manipulation.md")
fi
if [ "$SHOW_SYSTEM" == true ]; then
	CHEATSHEETS_TO_SHOW+=("system.md")
fi
if [ "$SHOW_TEXT_MANIPULATION" == true ]; then
	CHEATSHEETS_TO_SHOW+=("text-manipulation.md")
fi

if [ "$SHOW_ALL" == true ]; then
	CHEATSHEETS_TO_SHOW=($(ls "$BASIC_SETUP_DIR/resources/cheatsheet-docs"))
fi

if ((${#CHEATSHEETS_TO_SHOW[@]} == 0)); then
	SHOW_HELP=true
fi

[ $SHOW_HELP == true ] && help && exit 0

cs_tmp_name="/tmp/cheatsheet-$(date +%s).md"
echo "" > "$cs_tmp_name"

for cheatsheet_to_show in "${CHEATSHEETS_TO_SHOW[@]}"; do
	current_content=$(write-a-cheatsheet $cheatsheet_to_show)
	echo "" >> "$cs_tmp_name"
	echo "$current_content" >> "$cs_tmp_name"
	echo "" >> "$cs_tmp_name"
done

if [ "$(general-command-installed -c bat)" == false ]; then
	less "$cs_tmp_name"
else
	bat -l md "$cs_tmp_name"
fi

rm $cs_tmp_name
