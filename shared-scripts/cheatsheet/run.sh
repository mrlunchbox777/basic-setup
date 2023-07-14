#! /usr/bin/env bash

cheatsheets_to_show="$1"
basic_setup_shared_scripts_dir=$(general-get-shared-scripts-dir)

if [[ "$cheatsheets_to_show" == "all" ]]; then
  cheatsheets_to_show="$(ls $basic_setup_shared_scripts_dir/../resources/cheatsheet-docs/ | cut -c 1 | tr -d '\n')"
fi

if [ -z "$cheatsheets_to_show" ]; then
  cheatsheets_to_show="i"
fi

cs_tmp_name="/tmp/cheatsheet_$(uuid).md"
echo "" > "$cs_tmp_name"

for cheatsheet_to_show in $(echo $cheatsheets_to_show | grep -o .); do
  current_content=$(cheatsheet-write-a-cheatsheet $cheatsheet_to_show)
  echo "" >> "$cs_tmp_name"
  echo "$current_content" >> "$cs_tmp_name"
  echo "" >> "$cs_tmp_name"
done

which_bat_output="$(which 'bat')"
if [ -z "$which_bat_output" ] || [[ "bat not found" == "$which_bat_output" ]]; then
  less "$cs_tmp_name"
else
  bat -l md "$cs_tmp_name"
fi

rm $cs_tmp_name
