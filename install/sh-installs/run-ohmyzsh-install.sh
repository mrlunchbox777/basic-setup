# run nvm install function
run-nvm-install-basic-setup () {
  # this checks for installed things already
  # Pulled from - https://github.com/ohmyzsh/ohmyzsh#basic-installation
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
