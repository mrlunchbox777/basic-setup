# cheatsheet

run-write-a-cheatsheet() {
  if [ "${#1}" != "1" ]; then
    echo "Only One character is allowed when running run-write-a-cheatsheet" >&2
    exit 1
  fi
  local cheatsheet_file_name=$(ls "$BASICSETUPGENERALRCDIR/../resources/cheatsheet-docs/" | grep ^$1)
  local cheatsheet_file_location="$BASICSETUPGENERALRCDIR/../resources/cheatsheet-docs/$cheatsheet_file_name"
  cat "$cheatsheet_file_location"
}

cheatsheet() {
  local cheatsheets_to_show="$1"
  if [[ "$cheatsheets_to_show" == "all" ]]; then
    local cheatsheets_to_show="$(ls $BASICSETUPGENERALRCDIR/../resources/cheatsheet-docs/ | cut -c 1 | tr -d '\n')"
  fi
  if [ -z "$cheatsheets_to_show" ]; then
    local cheatsheets_to_show="i"
  fi
  cs_tmp_name="/tmp/cheatsheet_$(uuid).md"
  echo "" > "$cs_tmp_name"
  for cheatsheet_to_show in $(echo $cheatsheets_to_show | grep -o .); do
    local current_content=$(run-write-a-cheatsheet $cheatsheet_to_show)
    echo "\n$current_content\n" >> "$cs_tmp_name"
  done
  local which_bat_output="$(which 'bat')"
  if [ -z "$which_bat_output" ] || [[ "bat not found" == "$which_bat_output" ]]; then
    less "$cs_tmp_name"
  else
    bat -l md "$cs_tmp_name"
  fi
  rm $cs_tmp_name
}

alias cs=cheatsheet
alias csa='cheatsheet all'
