#! /usr/bin/env bash

# include the how function
how-function() {
	local COMMAND="$1"
	local BEFORE_CONTEXT="$2"
	local AFTER_CONTEXT="$3"
	local LANGUAGE="$4"
	local VERBOSITY="$5"

	if [ -z "$COMMAND" ]; then
		echo "Error: Argument for -c is missing" >&2
		how --help
		return 1
	fi
	if [ -z "$BEFORE_CONTEXT" ]; then
		BEFORE_CONTEXT=3
	fi
	if [ -z "$AFTER_CONTEXT" ]; then
		AFTER_CONTEXT=$(echo "$BEFORE_CONTEXT + 2" | bc)
	fi
	if [ -z "$LANGUAGE" ]; then
		LANGUAGE="bash"
	fi
	if [ -z "$VERBOSITY" ]; then
		VERBOSITY=0
	fi

	local type_output=$(type "$COMMAND" 2>&1)
	local error_output=$(echo "$type_output" | grep '^.*how: line [0-9]*: type: '$COMMAND': not found$')
	if [ ! -z "$error_output" ]; then
		echo "ERROR: $error_output" >&2
		how --help
		return 1
	fi

	local alias_output=$(echo "$type_output" | grep '^.* is an alias for .*$')
	local builtin_output=$(echo "$type_output" | grep '^.* is a shell builtin$')
	[ "$VERBOSITY" -gt 0 ] && echo "command: $COMMAND"
	[ "$VERBOSITY" -gt 0 ] && echo "type_output: $type_output"
	[ "$VERBOSITY" -gt 0 ] && echo "alias_output: $alias_output"
	[ "$VERBOSITY" -gt 0 ] && echo "builtin_output: $builtin_output"

	local how_after=""
	if [ ! -z "$alias_output" ]; then
		local how_output="$type_output"
		local how_after="$(echo "$type_output" | sed 's/^.* is an alias for\s//g' | awk '{print $1}')"
	else
		local how_output="$type_output"
		local how_force="$type_output"
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
		local symlink_string="^ Pulled from symlink - $file_path -> $next_file_path"
		while [ -L "$next_file_path" ]; do
			local readlink_output="$(readlink "$next_file_path")"
			if [ "$(echo "1 + ${#readlink_output}" | bc)" -eq "$(echo $readlink_output | sed 's|^/||' | wc -m)" ]; then
				local next_file_path="$(realpath --no-symlinks "$(dirname "$next_file_path")/$readlink_output")"
			else
				local next_file_path="$(realpath --no-symlinks "$readlink_output")"
			fi
			local symlink_string="$symlink_string -> $next_file_path"
		done
		local how_output=$(echo -e "--" && cat "$next_file_path" && echo -e "--" && echo "$symlink_string" && echo -e "--")
	elif [ -z "$how_after" ]; then
		local how_output=$(echo "$file_path" | \
			xargs -I % bash -c "echo -e \"--\" && \
				file_output=\"\$(file \"%\")\" && \
				if [[ \"\$file_output\" =~ executable ]]; then echo \"\$file_output\"; else grep -B \"$BEFORE_CONTEXT\" -A \"$AFTER_CONTEXT\" \"$COMMAND\" \"%\" 2>&1; fi && \
				echo -e \"--\n^ Pulled from - %\n--\n\"
			"
		)
	fi

	local error_output=$(echo "$how_output" | grep '^grep: found: No such file or directory$')
	if [ ! -z "$error_output" ]; then
		echo "ERROR: $error_output" >&2
		echo "ERROR: consider running with howa instead of how, this may be an alias." >&2
		how --help
		return 1
	fi

	if [ ! -z "$how_force" ]; then
		local how_output="$how_force"
		local how_after=""
	fi

	if [ -z "$how_after" ]; then
		if [ "$(echo "$(general-command-installed bat)" | sed 's/true//' | wc -m)" -eq 1 ]; then
			echo "$how_output" | bat -l "$LANGUAGE"
		else
			echo "$how_output"
		fi
	else
		echo "--"
		echo "$COMMAND is an alias for $how_after"
		echo "running 'howa \"$how_after\" \"$AFTER_CONTEXT\" \"$BEFORE_CONTEXT\" \"$LANGUAGE\" $VERBOSITY'"
		echo "--"
		how-function "$how_after" "$AFTER_CONTEXT" "$BEFORE_CONTEXT" "$LANGUAGE" $VERBOSITY
	fi
}
