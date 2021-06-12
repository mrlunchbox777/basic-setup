# Init script for worskstation

# Pulled from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# track directories
INITIAL_DIR="$(pwd)"
cd "$DIR"

# update everything
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# install stuff from apt
sudo apt-get install firefox gpg git kleopatra terraform wget zsh -y

# grab submodules
git submodule update --recursive --remote

# install vscode
if [ -z $(which code) ]; then
  # pulled from https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
  wget -q https://go.microsoft.com/fwlink/?LinkID=760868 -O vs_code.deb
  sudo dpkg -i ./vs_code.deb
  rm vs_code.deb
  sudo apt-get install -f
fi

# install nvm
if [ -z $(which nvm) ]; then
  # pulled from https://github.com/nvm-sh/nvm#installing-and-updating
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  nvm install node
  nvm use node
fi

# install powershell
if [ -z $(which pwsh) ]; then
  # pulled from https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004
  # Update the list of packages
  sudo apt-get update
  # Install pre-requisite packages.
  sudo apt-get install -y wget apt-transport-https software-properties-common
  # Download the Microsoft repository GPG keys
  wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft.deb
  # Register the Microsoft repository GPG keys
  sudo dpkg -i packages-microsoft-prod.deb
  # Update the list of products
  sudo apt-get update
  # Enable the "universe" repositories
  sudo add-apt-repository universe
  # Install PowerShell
  sudo apt-get install -y powershell
  # Start PowerShell
  # pwsh
  # Remove package
  rm packages-microsoft.deb
fi

# install dotnet
if [ -z $(which dotnet) ]; then
  # pulled from https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
  wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  sudo apt-get update
  sudo apt-get install -y apt-transport-https
  sudo apt-get update
  sudo apt-get install -y dotnet-sdk-5.0 aspnetcore-runtime-5.0
  rm packages-microsoft-prod.deb
fi

# update the gitconfig
if [ -z $(grep "path = .*gitconfig" ~/.gitconfig) ]; then
  echo -e "\n[include]\n  path = \"$DIR/gitconfig\"" >> ~/.gitconfig
fi

# change the default shell to zsh
if [[ ! "$SHELL" =~ .*"zsh" ]]; then
  chsh -s $(which zsh)
fi

# move back to original dir and update user
cd "$INITIAL_DIR"
echo "init script complete, you should probably restart your terminal and/or your computer"
