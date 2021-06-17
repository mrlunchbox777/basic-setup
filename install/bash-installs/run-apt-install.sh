# run apt install function
run-apt-install-basic-setup () {
  check_for_run_variable_name="should_install_$(echo $1 | sed -r 's/-/_/g')"
  if [ "${!check_for_run_variable_name}" == true ]; then
    if [ -z $(which $1) ]; then
      sudo apt-get install $1 -y
    else
      echo "$1 already installed, skipping."
    fi
  else
    echo "Skipping install for $1..."
  fi
}
