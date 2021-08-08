# cheatsheet

run-write-a-cheatsheet() {
  if [ "${#1}" != "1" ]; then
    echo "Only One character is allowed when running run-write-a-cheatsheet" >&2
    exit 1
  fi
  local cheatsheet_file_name=$(ls $BASICSETUPGENERALRCDIR/sh/cheatsheet-docs/ | grep ^$1)
  local cheatsheet_file_location="$BASICSETUPGENERALRCDIR/sh/cheatsheet-docs/$cheatsheet_file_name"
  if [ -z $(which bat) ]; then
    cat "$cheatsheet_file_location"
  else
    bat -l md "$cheatsheet_file_location"
  fi
}

cheatsheet() {
  local cheatsheets_to_show="$1"
  if [ -z "$cheatsheets_to_show" ]; then
    cheatsheets_to_show="i"
  fi
  for cheatsheet_to_show in $(echo $cheatsheets_to_show | grep -o .); do
    run-write-a-cheatsheet "$cheatsheet_to_show"
  done
}

alias cs=cheatsheet
