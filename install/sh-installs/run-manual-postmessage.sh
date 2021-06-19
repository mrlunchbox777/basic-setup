# run manual postmessage function
run-manual-postmessage-basic-setup () {
  check_for_run_variable_name="should_postmessage_$1"
  if [ "$check_for_run_variable_name" == "true" ]; then
    source_variable_name="sh-installs/run-$1-postmessage.sh"
    function_variable_name="run-$1-postmessage-basic-setup"
    source "$source_variable_name"
    $function_variable_name
  else
    echo "Skipping postmessage for $1..."
  fi
}

run-manual-postmessage-many-basic-setup () {
  for f in "$@"
  do
    run-manual-postmessage-basic-setup "$f"
  done
}
