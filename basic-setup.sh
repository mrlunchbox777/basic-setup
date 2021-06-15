#!/bin/bash

# clones and installs the basic setup

currentDir="$(pwd)"

mkdir -p ~/src/tools
cd ~/src/tools

sudo apt-get update -y
sudo apt-get install git bash -y
sudo apt-get autoremove -y

if [ ! -d basic-setup ]; then
  git clone https://github.com/mrlunchbox777/basic-setup
fi

cd basic-setup

bash ./install/init.sh | tee basic-setup-output.txt

cd "$currentDir"
