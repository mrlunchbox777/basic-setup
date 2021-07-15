# run install mailutils function
run-install-mailutils-basic-setup () {
  if [ -z $(which mail) ]; then
    # https://devanswers.co/you-have-mail-how-to-read-mail-in-ubuntu/
    sudo apt-get install --assume-yes mailutils
  fi
}
