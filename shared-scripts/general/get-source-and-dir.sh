#! /usr/bin/env bash

# TODO: maybe we should look to handle calling from interactive rather than just scripts, also fix the help docs

# Adapted from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
run_get_source_and_dir_help_string=""
run_get_source_and_dir_help_string+="error - no source passed in\\n"
run_get_source_and_dir_help_string+="pass in source using the following\\n"
run_get_source_and_dir_help_string+="\\n"
run_get_source_and_dir_help_string+="* sh - source=\"\$0\"\\n"
run_get_source_and_dir_help_string+="* bash - source=\"\${BASH_SOURCE[0]}\"\\n"
run_get_source_and_dir_help_string+="* zsh - source=\"\${(%):-%x}\"\\n"
run_get_source_and_dir_help_string+="\\n"
run_get_source_and_dir_help_string+="output - rgsd=(\"source\", \"dir\")\\n"
run_get_source_and_dir_help_string+="to use run -\\n"
run_get_source_and_dir_help_string+="  sd=\"\$(get-sandd \"\$source\")\"\\n"
run_get_source_and_dir_help_string+="  or sd=\"\$(get-source-and-dir \"\$source\")\"\\n"
run_get_source_and_dir_help_string+="    source=\"\$(echo \"\$sd\" | jq -r .source)\"\\n"
run_get_source_and_dir_help_string+="    dir=\"\$(echo \"\$sd\" | jq -r .dir)\"\\n"
run_get_source_and_dir_help_string+="\\n"
run_get_source_and_dir_help_string+="after the eval statement\\n"
run_get_source_and_dir_help_string+="* \$source will be set to source resolving symlinks relative to calling pwd\\n"
run_get_source_and_dir_help_string+="* \$dir will be set to the absolute parent dir of \$source\\n"

source="$1"
dir=""

if [ -z "$source" ]; then
	echo -e "$run_get_source_and_dir_help_string" >&2
	[[ $- == *i* ]] && exit 1
fi

while [ -L "$source" ]; do # resolve $source until the file is no longer a symlink
	dir="$( cd -P "$( dirname "$source" )" > /dev/null 2>&1 && pwd )"
	source="$(readlink "$source")"
	[[ $source != /* ]] && \
		source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
dir="$( cd -P "$( dirname "$source" )" > /dev/null 2>&1 && pwd )"
echo "{\"source\": \"$source\", \"dir\": \"$dir\"}"
