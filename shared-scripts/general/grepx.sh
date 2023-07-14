#! /usr/bin/env bash

current_command=$2
if [ -z "$current_command" ]; then
  current_command="code"
fi
grep -r "$1" | sed 's/:.*//' | sort -u | xargs -I % sh -c "$current_command \"%\""
