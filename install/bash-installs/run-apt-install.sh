# run apt install function
run-apt-install-basic-setup () {
  if [ "$2" == true ]; then
    if [ -z $(which $1) ]; then
      sudo apt-get install $1 -y
    else
      echo "$1 already installed, skipping."
    fi
  else
    echo "Skipping install for $1..."
  fi
}
