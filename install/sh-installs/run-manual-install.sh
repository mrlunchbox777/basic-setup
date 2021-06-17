# run manual install function
run-manual-install-basic-setup () {
  check_for_run_variable_name="should_install_$1"
  if [ "$check_for_run_variable_name" == "true" ]; then
    source_variable_name="bash-installs/run-$1-install.sh"
    function_variable_name="run-$1-install-basic-setup"
    source "$source_variable_name"
    $function_variable_name
  else
    echo "Skipping install for $1..."
  fi
}

run-manual-install-many-basic-setup () {
  for f in "$@"
  do
    run-manual-install-basic-setup "$f"
  done
}
