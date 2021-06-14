# Init script for worskstation

# Pulled from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Set variables
should_do_full_update=${BASICSETUPSHOULDDOFULLUPDATE:-true}
should_do_submodule_update=${BASICSETUPSHOULDDOSUBMODULEUPDATE:-true}
should_install_code=${BASICSETUPSHOULDINSTALLCODE:-true}
should_install_nvm=${BASICSETUPSHOULDINSTALLNVM:-true}
should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-true}

# track directories
INITIAL_DIR="$(pwd)"
cd "$DIR"

# update everything
if [ "$should_do_full_update" == "true" ]; then
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
fi

# install stuff from apt
sudo apt-get install bat firefox gpg git kleopatra terraform tmux wget zsh -y

# grab submodules
if [ "$should_do_submodule_update" == "true" ]; then
  git submodule update --recursive --remote
fi

# install vscode
if [ $should_install_code == "true" ]; then
  source bash-installs/run-code-install.sh
  run-code-install-basic-setup
fi

# install nvm
if [ $should_install_nvm == "true" ]; then
  source bash-installs/run-nvm-install.sh
  run-nvm-install-basic-setup
fi

# install powershell
if [ $should_install_pwsh == "true" ]; then
  source bash-installs/run-pwsh-install.sh
  run-pwsh-install-basic-setup
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
if [ -z "$(grep 'path = .*gitconfig' ~/.gitconfig)" ]; then
  echo -e "\n[include]\n  path = \"$DIR/gitconfig\"" >> ~/.gitconfig
fi

# change the default shell to zsh
if [[ ! "$SHELL" =~ .*"zsh" ]]; then
  echo "********************************************************"
  echo "To change to zsh run the following:"
  echo ""
  echo 'chsh -s $(which zsh)'
  echo ""
  echo "********************************************************"
fi

# move back to original dir and update user
cd "$INITIAL_DIR"
echo "init script complete, you should probably restart your terminal and/or your computer"
