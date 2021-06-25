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
    local current_run_manual_install_snap_many_basic_setup_f="$(echo $run_manual_install_snap_many_basic_setup_f | xargs echo)"
    local check_for_run_variable_name="should_install_$(echo $current_run_manual_install_snap_many_basic_setup_f | sed -r 's/-/_/g')"
    if [ "${!check_for_run_variable_name}" == true ]; then
      if [ -z "$(which $current_run_manual_install_snap_many_basic_setup_f)" ]; then
        snap_install_string+="$current_run_manual_install_snap_many_basic_setup_f "
      else
        echo "$current_run_manual_install_snap_many_basic_setup_f already installed, skipping."
      fi
    else
      echo "Skipping install for $current_run_manual_install_snap_many_basic_setup_f..."
    fi
  done

  snap_install_string="$(echo $snap_install_string | xargs echo)"
  if [ ! -z "$snap_install_string" ]; then
    sudo snap install "$snap_install_string" 
  fi
}
