#! /usr/bin/env bash

basic_setup_shared_scripts_dir=$(general-get-shared-scripts-dir)

if [ "${#1}" != "1" ]; then
	echo "Only One character is allowed when running run-write-a-cheatsheet" >&2
	exit 1
fi

cheatsheet_file_name=$(ls "$basic_setup_shared_scripts_dir/../resources/cheatsheet-docs/" | grep ^$1)
cheatsheet_file_location="$basic_setup_shared_scripts_dir/../resources/cheatsheet-docs/$cheatsheet_file_name"
cat "$cheatsheet_file_location"
