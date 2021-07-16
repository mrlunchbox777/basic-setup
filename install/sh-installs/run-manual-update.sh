# run manual update function
run-manual-update-basic-setup () {
  local check_for_run_variable_name="should_update_$(echo $1 | sed -r 's/-/_/g')"
  if [ "${!check_for_run_variable_name}" == "true" ]; then
    local source_variable_name="sh-installs/run-update-$1.sh"
    local function_variable_name="run-update-$1-basic-setup"
    source "$source_variable_name"
    $function_variable_name
  else
    echo "Skipping update for $1..."
  fi
}

run-manual-update-many-basic-setup () {
  for run_manual_update_many_basic_setup_f in "$@"
  do
    run-manual-update-basic-setup "$run_manual_update_many_basic_setup_f"
  done
}
