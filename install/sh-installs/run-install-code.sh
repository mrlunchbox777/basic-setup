# run install code function
run-install-code-basic-setup () {
  if [ -z $(which code) ]; then
    # pulled from https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
    wget -q https://go.microsoft.com/fwlink/?LinkID=760868 -O vs_code.deb
    sudo dpkg -i ./vs_code.deb
    rm vs_code.deb
    sudo apt-get install -f
  fi
}
