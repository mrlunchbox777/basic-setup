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
should_install_ui_tools=${BASICSETUPSHOULDINSTALLUITOOLS:-true}

should_install_zsh=${BASICSETUPSHOULDINSTALLZSH:-true}

should_install_code=${BASICSETUPSHOULDINSTALLCODE:-true}
should_install_dotnet=${BASICSETUPSHOULDINSTALLDOTNET:-true}
should_install_nvm=${BASICSETUPSHOULDINSTALLNVM:-true}
should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-true}

should_update_gitconfig=${BASICSETUPSHOULDUPDATEGITCONFIG:-true}

# track directories
INITIAL_DIR="$(pwd)"
cd "$DIR"

# update everything
if [ "$should_do_full_update" == "true" ]; then
  source bash-installs/run-full-update.sh
  run-full-update-basic-setup
fi

## apt Installs
echo "********************************************************"
echo ""
echo "Starting apt Installs"
echo ""
echo "********************************************************"

source bash-installs/run-apt-install.sh

if [ $should_install_ui_tools == "true" ]; then
  run-apt-install-basic-setup firefox true
  run-apt-install-basic-setup kleopatra true
fi

run-apt-install-basic-setup bat true
run-apt-install-basic-setup git true
run-apt-install-basic-setup gpg true
run-apt-install-basic-setup terraform true
run-apt-install-basic-setup tmux true
run-apt-install-basic-setup wget true
run-apt-install-basic-setup zsh "$should_install_zsh"

## Manual Installs
echo "********************************************************"
echo ""
echo "Starting git submodule update"
echo ""
echo "********************************************************"

# grab submodules
if [ "$should_do_submodule_update" == "true" ]; then
  source bash-installs/run-gitsubmodule-update.sh
  run-gitsubmodule-update-basic-setup
fi

## Manual Installs
echo "********************************************************"
echo ""
echo "Starting Manual Installs"
echo ""
echo "********************************************************"

# install vscode
if [ $should_install_ui_tools == "true" ]; then
  if [ $should_install_code == "true" ]; then
    source bash-installs/run-code-install.sh
    run-code-install-basic-setup
  fi
fi

# install dotnet
if [ $should_install_dotnet == "true" ]; then
  source bash-installs/run-dotnet-install.sh
  run-dotnet-install-basic-setup
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

# update the gitconfig
if [ $should_update_gitconfig == "true" ]; then
  source bash-installs/run-gitconfig-update.sh
  run-gitconfig-update-basic-setup
fi

## Post-install messages
echo "********************************************************"
echo ""
echo "Starting Post-install Messages"
echo ""
echo "********************************************************"

# change the default shell to zsh
if [ $should_install_zsh == "true" ]; then
  source bash-installs/run-zsh-installmessage.sh
  run-zsh-installmessage-basic-setup
fi

# move back to original dir and update user
cd "$INITIAL_DIR"
echo "init script complete, you should probably restart your terminal and/or your computer"
