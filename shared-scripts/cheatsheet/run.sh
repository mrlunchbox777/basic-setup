#! /usr/bin/env bash

#
# global defaults
#
CHEATSHEETS_TO_SHOW=()
SHOW_ALL=false
SHOW_HELP=false
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
		description: prints cheatsheets to the terminal
		----------
		--all        - (flag, default: false) Show all cheatsheets.
		-h|--help    - (flag, default: false) Print this help message and exit.
		-v|--verbose - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		examples:
		print cheatsheet index - $command_for_help
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
	--all)
		SHOW_ALL=true
		shift
		;;
	# install command flag
	-c | --install-command)
		if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
			INSTALL_COMMAND="$2"
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

if [ "$SHOW_ALL" == true ]; then
	CHEATSHEETS_TO_SHOW=$(ls "$BASIC_SETUP_DIR/resources/cheatsheet-docs")
fi

if [ -z "$cheatsheets_to_show" ]; then
	CHEATSHEETS_TO_SHOW="index.md"
fi

cs_tmp_name="/tmp/cheatsheet-$(date +%s).md"
echo "" > "$cs_tmp_name"

for cheatsheet_to_show in "$CHEATSHEETS_TO_SHOW"; do
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
