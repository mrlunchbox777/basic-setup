#!/bin/sh
# clones and installs the basic setup

current_dir="$(pwd)"
env_path=""

mkdir -p ~/src/tools
[ -f .env ] && env_path="$(pwd)/.env"
cd ~/src/tools

sudo apt-get update -y
sudo apt-get install git bash -y
sudo apt-get autoremove -y

if [ ! -d basic-setup ]; then
  git clone https://github.com/mrlunchbox777/basic-setup
fi

cd basic-setup
echo "current dir - $(pwd)"
[ ! -z "$env_path" ] && cp "$env_path" ./.env
bash install/init.sh | tee basic-setup-sh-output.log

should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-true}
if "${should_install_pwsh}" ; then
  echo "running pwsh for linux"
  # copy .env
  # include the alias only env var
  pwsh -c "./install/init.ps1" | tee ./basic-setup-pwsh-output.log
else
  echo "not running pwsh for linux"
fi

## end of basic setup
echo "\n\n"
echo "**********************************************************"
echo "* Finished Basic Setup" 
echo "*   Check -"
echo "*     ~/src/tools/basic-setup/basic-setup-sh-output.log"
echo "*   It will have logs and outputs on everything installed."
echo "**********************************************************"

cd "$current_dir"
