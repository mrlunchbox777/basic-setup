#!/bin/bash

# clones and installs the basic setup

currentDir="$(pwd)"

mkdir -p ~/src/tools
cd ~/src/tools

sudo apt update -y
sudo apt install git bash -y
sudo apt autoremove -y

if [ ! -d basic-setup ]; then
  git clone https://github.com/mrlunchbox777/basic-setup
fi

cd basic-setup

bash ./install/init.sh

cd "$currentDir"
