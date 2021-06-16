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
for f in $(ls ./shared-scripts/sh/); do source ./shared-scripts/sh/$f; done

bash ./install/init.sh | tee basic-setup-output.txt

## end of basic setup
send-message \
"Finished Basic Setup" \
"  Check -" \
"    ~/src/tools/basic-setup/basic-setup-output.txt" \
"  It will have logs and outputs on everything installed."

cd "$currentDir"
