#! /usr/bin/env bash

#
# global defaults
#
AFTER_CONTEXT=0
BEFORE_CONTEXT=3
COMMAND=""
LANGUAGE="sh"
SHOW_HELP=false
VERBOSITY=0

#
# helper functions
#

# script help message
help() {
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
		check source of how - $command_for_help -c how
		----------
	EOF
}

# get the test value for the operating system
how_function() {
	# this is WIP and not working yet
	local type_output=$(type "$COMMAND" 2>&1)
	local error_output=$(echo "$type_output" | grep '^.*how: line [0-9]*: type: '$COMMAND': not found$')
	if [ ! -z "$error_output" ]; then
		echo "ERROR: $error_output" >&2
		help
		exit 1
	fi
	local alias_output=$(echo "$type_output" | grep '^\w* is an alias for .*$')
	[ "$VERBOSITY" -gt 0 ] && echo "command: $COMMAND"
	[ "$VERBOSITY" -gt 0 ] && echo "type_output: $type_output"
	[ "$VERBOSITY" -gt 0 ] && echo "alias_output: $alias_output"
	local how_after=""
	if [ ! -z "$alias_output" ]; then
		local how_output="$type_output"
		local how_after="$(echo "$type_output" | sed 's/^\w* is an alias for\s//g' | awk '{print $1}')"
	fi
	local file_path="$(echo "$type_output" | awk -F " " '{print $NF}')"
	[ "$VERBOSITY" -gt 0 ] && echo "file_path: $file_path"
	if [ -L "$file_path" ]; then
		local readlink_output="$(readlink "$file_path")"
		if [ "$(echo "1 + ${#readlink_output}" | bc)" -eq "$(echo $readlink_output | sed 's|^/||' | wc -m)" ]; then
			local next_file_path="$(realpath --no-symlinks "$(dirname "$file_path")/$readlink_output")"
		else
			local next_file_path="$(realpath --no-symlinks "$readlink_output")"
		fi
		local symlink_string="pulled from symlink - $file_path -> $next_file_path"
		while [ -L "$next_file_path" ]; do
			local next_file_path="$(realpath --no-symlinks "$(dirname "$next_file_path")/$(readlink "$next_file_path")")"
			local symlink_string+=" -> $next_file_path"
		done
		local how_output=$(echo "--\n" && cat "$next_file_path" && echo "--" && echo "$symlink_string" && echo "\n")
	else
		local how_output=$(echo "$file_path" | \
			xargs -I % bash -c "echo \"--\" && \
				file_output=\"\$(file \"%\")\" && \
				if [[ \"\$file_output\" =~ executable ]]; then echo \"\$file_output\"; else grep -B \"$BEFORE_CONTEXT\" -A \"$AFTER_CONTEXT\" \"$COMMAND\" \"%\"; fi && \
				echo \"--\nPulled from - %\n\"
			"
		)
	fi
	if [ "$(echo "$(general-command-installed bat)" | sed 's/true//' | wc -m)" -eq 1 ]; then
		echo "$how_output" | bat -l "$LANGUAGE"
	else
		echo "$how_output"
	fi
	if [ ! -z "$how_after" ]; then
		local extra_args=""
		for i in $(seq 1 $VERBOSITY); do
			extra_args="$extra_args -v"
		done
		echo ""
		echo "--"
		echo "- running 'how $how_after'"
		echo "--"
		echo ""
		how "$how_after" -a "$AFTER_CONTEXT" -b "$BEFORE_CONTEXT" -l "$LANGUAGE" $extra_args
	fi
}

#
# CLI parsing
#
PARAMS=""
# while [ $# -gt 0 ]; do
while (("$#")); do
	case "$1" in
	# after optional argument
	-a | --after)
		# if [ -n "$2" ] && [ "$(echo "1 + ${#2}" | bc)" -eq "$(echo "$2" | sed 's/^\-//' | wc -m)" ]; then
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
		# VERBOSITY=$(echo "$VERBOSITY + 1" | bc)
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
# [ "$(echo "SHOW_HELP" | sed 's/true//' | wc -m)" -eq 1 ] && help && exit 0
[ $SHOW_HELP == true ] && help && exit 0

[ -z "$COMMAND" ] && echo "Error: Argument for -c is missing" >&2 && help && exit 1
AFTER_CONTEXT=$(( $BEFORE_CONTEXT + 2))
how_function
