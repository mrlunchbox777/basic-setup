# run install code function
run-install-code-basic-setup () {
  if [ -z $(which code) ]; then
    # pulled from https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
    curl -1fLsq https://go.microsoft.com/fwlink/?LinkID=760868 -o vs_code.deb
    sudo dpkg -i ./vs_code.deb
    rm vs_code.deb
    sudo apt-get install -f
  fi
}
