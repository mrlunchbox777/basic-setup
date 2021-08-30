# run full update function
run-full-update-basic-setup() {
  sudo apt-get update -y
  sudo apt-get -u upgrade --assume-no
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
}
