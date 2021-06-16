# Init script for worskstation

## Pulled from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# Set variables
## General variables
should_do_full_update=${BASICSETUPSHOULDDOFULLUPDATE:-true}
should_do_submodule_update=${BASICSETUPSHOULDDOSUBMODULEUPDATE:-true}
should_install_ui_tools=${BASICSETUPSHOULDINSTALLUITOOLS:-true}

## Apt variables
should_install_firefox=${BASICSETUPSHOULDINSTALLFIREFOX:-true}
should_install_kleopatra=${BASICSETUPSHOULDINSTALLKLEOPATRA:-true}

should_install_bat=${BASICSETUPSHOULDINSTALLBAT:-true}
should_install_calc=${BASICSETUPSHOULDINSTALLCALC:-true}
should_install_git=${BASICSETUPSHOULDINSTALLGIT:-true}
should_install_gpg=${BASICSETUPSHOULDINSTALLGPG:-true}
should_install_jq=${BASICSETUPSHOULDINSTALLJQ:-true}
should_install_sshclient=${BASICSETUPSHOULDINSTALLSSHCLIENT:-true}
should_install_terraform=${BASICSETUPSHOULDINSTALLTERRAFORM:-true}
should_install_tmux=${BASICSETUPSHOULDINSTALLTMUX:-true}
should_install_wget=${BASICSETUPSHOULDINSTALLWGET:-true}
should_install_zsh=${BASICSETUPSHOULDINSTALLZSH:-true}

## Manual Install variables
should_install_code=${BASICSETUPSHOULDINSTALLCODE:-true}

should_install_dotnet=${BASICSETUPSHOULDINSTALLDOTNET:-true}
should_install_nvm=${BASICSETUPSHOULDINSTALLNVM:-true}
should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-true}

## Config variables
should_update_gitconfig=${BASICSETUPSHOULDUPDATEGITCONFIG:-true}

# track directories
INITIAL_DIR="$(pwd)"
cd "$DIR"
for f in $(ls ../shared-scripts/sh/); do source ../shared-scripts/sh/$f; done

# update everything
if [ "$should_do_full_update" == "true" ]; then
  source bash-installs/run-full-update.sh
  run-full-update-basic-setup
fi

send-message "Starting apt Installs"

source bash-installs/run-apt-install.sh
alias raibs=run-apt-install-basic-setup

if [ $should_install_ui_tools == "true" ]; then
  raibs firefox "$should_install_firefox"
  raibs kleopatra "$should_install_kleopatra"
fi

raibs bat "$should_install_bat"
raibs calc "$should_install_calc"
raibs git "$should_install_git"
raibs gpg "$should_install_gpg"
raibs jq "$should_install_jq"
raibs openssh-client "$should_install_sshclient"
raibs terraform "$should_install_terraform"
raibs tmux "$should_install_tmux"
raibs wget "$should_install_wget"
raibs zsh "$should_install_zsh"

send-message "Starting git submodule update"

# grab submodules
if [ "$should_do_submodule_update" == "true" ]; then
  source bash-installs/run-gitsubmodule-update.sh
  run-gitsubmodule-update-basic-setup
fi

send-message "Starting Manual Installs"

# install vscode
if [ "$should_install_ui_tools" == "true" ]; then
  if [ "$should_install_code" == "true" ]; then
    source bash-installs/run-code-install.sh
    run-code-install-basic-setup
    # maybe look at installing vscode extensions here
  fi
fi

# install dotnet
if [ "$should_install_dotnet" == "true" ]; then
  source bash-installs/run-dotnet-install.sh
  run-dotnet-install-basic-setup
fi

# install nvm
if [ "$should_install_nvm" == "true" ]; then
  source bash-installs/run-nvm-install.sh
  run-nvm-install-basic-setup
fi

# install powershell
if [ "$should_install_pwsh" == "true" ]; then
  source bash-installs/run-pwsh-install.sh
  run-pwsh-install-basic-setup
fi

send-message "Starting Config Updates"

# update the gitconfig
if [ "$should_update_gitconfig" == "true" ]; then
  source bash-installs/run-gitconfig-update.sh
  run-gitconfig-update-basic-setup
fi

## need to ln -s for batcat
if [ "$should_install_bat" == "true" ]; then
  source bash-installs/run-batcat-update.sh
  run-batcat-update-basic-setup
fi

## Post-install messages
send-message "Starting Post-install Messages"

# change the default shell to zsh
if [ "$should_install_zsh" == "true" ]; then
  source bash-installs/run-zsh-installmessage.sh
  run-zsh-installmessage-basic-setup
fi

# move back to original dir and update user
cd "$INITIAL_DIR"
echo "init script complete, you should probably restart your terminal and/or your computer"
