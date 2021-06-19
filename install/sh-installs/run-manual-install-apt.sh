# run manual install apt function
run-manual-install-apt-basic-setup () {
  check_for_run_variable_name="should_install_$(echo $1 | sed -r 's/-/_/g')"
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
  apt_install_string=""
  for f in "$@"
  do
    check_for_run_variable_name="should_install_$(echo $f | sed -r 's/-/_/g')"
    if [ "${!check_for_run_variable_name}" == true ]; then
      if [ -z "$(dpkg -l | grep $f)" ]; then
        apt_install_string+="$f "
      else
        echo "$f already installed, skipping."
      fi
    else
      echo "Skipping install for $f..."
    fi
  done

  sudo apt-get install "$apt_install_string" -y
}
