# run apt install function
run-apt-install-basic-setup () {
  if [ "$2" == true ]; then
    sudo apt-get install $1 -y
  else
    echo "Skipping install for $1..."
  fi
}
