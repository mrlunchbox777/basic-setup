#!/bin/sh

# clones and installs the basic setup

current_dir="$(pwd)"

mkdir -p ~/src/tools
cd ~/src/tools

sudo apt-get update -y
sudo apt-get install git bash -y
sudo apt-get autoremove -y

if [ ! -d basic-setup ]; then
  git clone https://github.com/mrlunchbox777/basic-setup
fi

echo "current dir - $(pwd)"
bash ~/src/tools/basic-setup/install/init.sh | tee ~/src/tools/basic-setup/basic-setup-sh-output.log

## end of basic setup
echo "\n\n"
echo "----------------------------------------------------------"
echo "- Finished Basic Setup" 
echo "-   Check -"
echo "-     ~/src/tools/basic-setup/basic-setup-sh-output.log"
echo "-   It will have logs and outputs on everything installed."
echo "----------------------------------------------------------"

cd "$current_dir"
