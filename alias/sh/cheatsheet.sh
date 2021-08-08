# TODO: add more cheatsheat stuff
# for alias cheatsheet names
# echo temp file name
# write to temp file
# this needs to check if that files exists, and if not recreate it

cheatsheet() {
  local cheatsheet_file_location="$BASICSETUPGENERALRCDIR/sh/cheatsheet-docs/base.md"
  if [ -z $(which bat) ]; then
    cat "$cheatsheet_file_location"
  else
    bat -l md "$cheatsheet_file_location"
  fi
}

alias cs=cheatsheet
