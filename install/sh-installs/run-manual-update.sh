# run manual update function
run-manual-update-basic-setup () {
  check_for_run_variable_name="should_update_$1"
  if [ "$check_for_run_variable_name" == "true" ]; then
    source_variable_name="sh-installs/run-$1-update.sh"
    function_variable_name="run-$1-update-basic-setup"
    source "$source_variable_name"
    $function_variable_name
  else
    echo "Skipping update for $1..."
  fi
}

run-manual-update-many-basic-setup () {
  for f in "$@"
  do
    run-manual-update-basic-setup "$f"
  done
}
