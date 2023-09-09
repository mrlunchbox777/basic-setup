#! /usr/bin/env bash

#
# global defaults
#
BEFORE_CONTEXT=3
COMMAND=""
LANGUAGE="sh"
SHOW_HELP=false
VERBOSITY=0

#
# computed values (often can't be alphabetical)
#
AFTER_CONTEXT=$(( $BEFORE_CONTEXT" + 2))

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
		description: Like which, but with more context.
		----------
		-a|--after    - (optional, default: ((-b + 2))) The amount of context to grab after, only applies if -c is a script.
		-b|--before   - (optional, default: 3) The amount of context to grab before, only applies if -c is a script.
		-c|--command  - (required) The command to search for.
		-h|--help     - (flag, default: false) Print this help message and exit.
		-l|--language - (optional, default: "sh") The command to search for, only applies if -c is a script.
		-v|--verbose  - (multi-flag, default: 0) Increase the verbosity by 1.
		----------
		note: this will run down the chain of aliases and/or symbolic links until it finds the actual command.
		----------
		examples:
		get os type          - $command_for_help
		check if os is linux - $command_for_help -l
		----------
	EOF
}

# get the test value for the operating system
how() {
	# this is WIP and not working yet
  local command_to_search=$1
  local context_before_to_grab=$2
  local bat_lanuage_to_use=$3
  local context_after_to_grab=$4
  if [ -z "$bat_lanuage_to_use" ]; then
    local bat_lanuage_to_use="sh"
  fi
  if [ -z "$context_before_to_grab" ]; then
    local context_before_to_grab="3"
  fi
  if [ -z "$context_after_to_grab" ]; then
    local context_after_to_grab=$(echo "$context_before_to_grab" + 2 | bc)
  fi
  local type_output=$(type -a "$command_to_search")
  local error_output=$(echo "$type_output" | grep '^\w* not found$')
  if [ ! -z "$error_output" ]; then
    echo "$error_output" >&2
    return 1
  fi
  local alias_output=$(echo "$type_output" | grep '^\w* is an alias for .*$')
  local how_after=""
  if [ ! -z "$alias_output" ]; then
    local how_output="$type_output"
    local how_after="$(echo "$type_output" | sed 's/^\w* is an alias for\s//g' | awk '{print $1}')"
  else
    local how_output=$(echo "$type_output" | awk -F " " '{print $NF}' | \
      xargs -I % sh -c "echo \"--\" && grep -B \"$context_before_to_grab\" \
      -A \"$context_after_to_grab\" \"$command_to_search\" \"%\" && echo \"--\\nPulled from - %\\n\"")
  fi
  if [ -z "$(which bat)" ]; then
    echo "$how_output"
  else
    echo "$how_output" | bat -l "$bat_lanuage_to_use"
  fi
  if [ ! -z "$how_after" ]; then
    echo ""
    echo "--"
    echo "- running 'how $how_after'"
    echo "--"
    echo ""
    how "$how_after" "$2" "$3" "$4" "$5"
  fi
}

#
# CLI parsing
#
PARAMS=""
while (("$#")); do
	case "$1" in
	# after optional argument
	-a | --after)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			AFTER_CONTEXT=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# before optional argument
	-b | --before)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			BEFORE_CONTEXT=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
		;;
	# command required argument
	-c | --command)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			COMMAND=$2
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
	# language optional argument
	-l | --language)
		if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
			LANGUAGE=$2
			shift 2
		else
			echo "Error: Argument for $1 is missing" >&2
			help
			exit 1
		fi
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

[ -z "$COMMAND" ] && echo "Error: Argument for -c is missing" >&2 && help && exit 1
