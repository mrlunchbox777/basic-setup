# run manual install function
run-manual-install-basic-setup () {
  local check_for_run_variable_name="should_install_$(echo $1 | sed -r 's/-/_/g')"
  if [ "${!check_for_run_variable_name}" == "true" ]; then
    local source_variable_name="sh-installs/run-install-$1.sh"
    local function_variable_name="run-install-$1-basic-setup"
    source "$source_variable_name"
    $function_variable_name
  else
    echo "Skipping install for $1..."
  fi
}

run-manual-install-many-basic-setup () {
  for run_manual_install_many_basic_setup_f in "$@"
  do
    run-manual-install-basic-setup "$run_manual_install_many_basic_setup_f"
  done
}
