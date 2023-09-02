#! /usr/bin/env bash

#
# global defaults
#
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
VERBOSITY=0

#
# computed values (often can't be alphabetical)
#
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
		-a|--alias   - (flag, default: false) Include alias.md.
		--all        - (flag, default: false) Show all cheatsheets, takes precendence.
		-b|--base    - (flag, default: false) Include base.md.
		-c|--compilation    - (flag, default: false) Include compilation.md.
		-d|--docker    - (flag, default: false) Include docker.md.
		-g|--general    - (flag, default: false) Include general.md.
		-h|--help    - (flag, default: false) Print this help message and exit.
		-i|--index   - (flag, default: false) Include index.md.
		-k|--kubernetes   - (flag, default: false) Include kubernetes.md.
		-m|--metrics   - (flag, default: false) Include metrics.md.
		-n|--networking   - (flag, default: false) Include networking.md.
		-p|--process-manipulation   - (flag, default: false) Include process-manipulation.md.
		-s|--system   - (flag, default: false) Include system.md.
		-t|--text-manipulation   - (flag, default: false) Include text-manipulation.md.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
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

if [ "$(general-command-installed bat)" == false ]; then
	less "$cs_tmp_name"
else
	bat -l md "$cs_tmp_name"
fi

rm $cs_tmp_name
