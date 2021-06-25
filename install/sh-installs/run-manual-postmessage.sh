# run manual postmessage function
run-manual-postmessage-basic-setup () {
  local check_for_run_variable_name="should_postmessage_$1"
  if [ "${!check_for_run_variable_name}" == "true" ]; then
    local source_variable_name="sh-installs/run-postmessage-$1.sh"
    local function_variable_name="run-postmessage-$1-basic-setup"
    source "$source_variable_name"
    $function_variable_name
  else
    echo "Skipping postmessage for $1..."
  fi
}

run-manual-postmessage-many-basic-setup () {
  for run_manual_postmessage_many_basic_setup_f in "$@"
  do
    run-manual-postmessage-basic-setup "$run_manual_postmessage_many_basic_setup_f"
  done
}