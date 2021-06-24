# run manual install snap function
run-manual-install-snap-basic-setup () {
  local check_for_run_variable_name="should_install_$(echo $1 | sed -r 's/-/_/g')"
  if [ "${!check_for_run_variable_name}" == true ]; then
    if [ -z "$(dpkg -l | grep $1)" ]; then
      sudo snap install $1
    else
      echo "$1 already installed, skipping."
    fi
  else
    echo "Skipping install for $1..."
  fi
}

run-manual-install-snap-many-basic-setup () {
  local snap_install_string=""
  for run_manual_install_snap_many_basic_setup_f in "$@"
  do
    local check_for_run_variable_name="should_install_$(echo $run_manual_install_snap_many_basic_setup_f | sed -r 's/-/_/g')"
    if [ "${!check_for_run_variable_name}" == true ]; then
      if [ -z "$(dpkg -l | grep $run_manual_install_snap_many_basic_setup_f)" ]; then
        snap_install_string+="$run_manual_install_snap_many_basic_setup_f "
      else
        echo "$run_manual_install_snap_many_basic_setup_f already installed, skipping."
      fi
    else
      echo "Skipping install for $run_manual_install_snap_many_basic_setup_f..."
    fi
  done

  sudo snap install "$snap_install_string"
}
