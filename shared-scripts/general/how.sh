#! /usr/bin/env bash

# TODO support links

command_to_search=$1
context_before_to_grab=$2
bat_lanuage_to_use=$3
context_after_to_grab=$4

if [ -z "$bat_lanuage_to_use" ]; then
  bat_lanuage_to_use="sh"
fi
if [ -z "$context_before_to_grab" ]; then
  context_before_to_grab="3"
fi
if [ -z "$context_after_to_grab" ]; then
  context_after_to_grab=$(echo "$context_before_to_grab" + 2 | bc)
fi

type_output=$(type -a "$command_to_search")
error_output=$(echo "$type_output" | grep '^\w* not found$')

if [ ! -z "$error_output" ]; then
  echo "$error_output" >&2
  return 1
fi

alias_output=$(echo "$type_output" | grep '^\w* is an alias for .*$')
how_after=""

if [ ! -z "$alias_output" ]; then
  how_output="$type_output"
  how_after="$(echo "$type_output" | sed 's/^\w* is an alias for\s//g' | awk '{print $1}')"
else
  how_output=$(echo "$type_output" | awk -F " " '{print $NF}' | \
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
