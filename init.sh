# Init script for worskstation

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y

sudo apt-get install gpg git -y

if [ -z $(which code) ]; then
  wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vs_code.deb
  sudo dpkg -i ./vs_code.deb
  rm vs_code.deb
  sudo apt-get install -f
fi

if [ -z $(which nvm) ]; then
  # pulled from https://github.com/nvm-sh/nvm#installing-and-updating
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
fi

if [ -z $(which pwsh) ]; then
  # pulled from https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004
  # Update the list of packages
  sudo apt-get update
  # Install pre-requisite packages.
  sudo apt-get install -y wget apt-transport-https software-properties-common
  # Download the Microsoft repository GPG keys
  wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
  # Register the Microsoft repository GPG keys
  sudo dpkg -i packages-microsoft-prod.deb
  # Update the list of products
  sudo apt-get update
  # Enable the "universe" repositories
  sudo add-apt-repository universe
  # Install PowerShell
  sudo apt-get install -y powershell
  # Start PowerShell
  pwsh
fi
