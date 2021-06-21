# run manual install apt function
run-manual-install-apt-basic-setup () {
  local check_for_run_variable_name="should_install_$(echo $1 | sed -r 's/-/_/g')"
  if [ "${!check_for_run_variable_name}" == true ]; then
    if [ -z "$(dpkg -l | grep $1)" ]; then
      sudo apt-get install $1 -y
    else
      echo "$1 already installed, skipping."
    fi
  else
    echo "Skipping install for $1..."
  fi
}

run-manual-install-apt-many-basic-setup () {
  local apt_install_string=""
  for run_manual_install_apt_many_basic_setup_f in "$@"
  do
    local check_for_run_variable_name="should_install_$(echo $run_manual_install_apt_many_basic_setup_f | sed -r 's/-/_/g')"
    if [ "${!check_for_run_variable_name}" == true ]; then
      if [ -z "$(dpkg -l | grep $run_manual_install_apt_many_basic_setup_f)" ]; then
        apt_install_string+="$run_manual_install_apt_many_basic_setup_f "
      else
        echo "$run_manual_install_apt_many_basic_setup_f already installed, skipping."
      fi
    else
      echo "Skipping install for $run_manual_install_apt_many_basic_setup_f..."
    fi
  done

  sudo apt-get install "$apt_install_string" -y
}
