# run install virtualboxextpack function
run-install-virtualboxextpack-basic-setup () {
  if [ -z $(which virtualbox-ext-pack) ]; then
    # https://askubuntu.com/questions/811488/command-to-accept-virtualbox-puel-for-virtualbox-ext-pack-installation
    echo virtualbox-ext-pack virtualbox-ext-pack/license select true | sudo debconf-set-selections
    sudo apt-get install virtualbox-ext-pack -y
  fi
}
