#!/bin/bash

# clones and installs the basic setup

currentDir="$(pwd)"

mkdir -p ~/src/tools
cd ~/src/tools

sudo apt update -y
sudo apt install git -y
sudo apt autoremove -y

git clone https://github.com/mrlunchbox777/basic-setup

cd basic-setup

bash ./init.sh

cd "$currentDir"
