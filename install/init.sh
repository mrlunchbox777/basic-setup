# Init script for worskstation

## Pulled from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink,
    # we need to resolve it relative to the path where the symlink file was located
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
should_install_openssh_client=${BASICSETUPSHOULDINSTALLOPENSSHCLIENT:-true}
should_install_terraform=${BASICSETUPSHOULDINSTALLTERRAFORM:-true}
should_install_tmux=${BASICSETUPSHOULDINSTALLTMUX:-true}
should_install_wget=${BASICSETUPSHOULDINSTALLWGET:-true}
should_install_zsh=${BASICSETUPSHOULDINSTALLZSH:-true}

## Manual Install variables
should_install_code=${BASICSETUPSHOULDINSTALLCODE:-true}

should_install_dotnet=${BASICSETUPSHOULDINSTALLDOTNET:-true}
should_install_nvm=${BASICSETUPSHOULDINSTALLNVM:-true}
should_install_ohmyzsh=${BASICSETUPSHOULDINSTALLOHMYZSH:-true}
should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-true}

## Postmessage variables
should_postmessage_zsh=${should_install_zsh}

## Config variables
should_update_gitconfig=${BASICSETUPSHOULDUPDATEGITCONFIG:-true}

# track directories
INITIAL_DIR="$(pwd)"
cd "$DIR"
for f in $(ls ../shared-scripts/sh/); do source ../shared-scripts/sh/$f; done

[ "$should_do_full_update" == "true" ] && run-full-update-basic-setup

send-message "Starting apt Installs"
source sh-installs/run-manual-install-apt.sh

[ $should_install_ui_tools == "true" ] && \
  run-manual-install-apt-many-basic-setup firefox kleopatra

run-manual-install-apt-many-basic-setup bat calc git gpg jq openssh-client terraform tmux wget zsh

send-message "Starting git submodule update"
[ "$should_do_submodule_update" == "true" ] && run-update-gitsubmodule-basic-setup

send-message "Starting Manual Installs"
source ./sh-installs/run-manual-install.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-install-many-basic-setup code

run-manual-install-many-basic-setup dotnet nvm ohmyzsh pwsh

send-message "Starting Config Updates"
source ./sh-installs/run-manual-update.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-update-many-basic-setup code

run-manual-update-many-basic-setup batcat gitconfig

# TODO: consider adding the powerlevel 10k theme to oh my zsh -
#   https://github.com/romkatv/powerlevel10k#installation

## Post-install messages
send-message "Starting Postmessages"
source ./sh-installs/run-manual-postmessage.sh

# [ "$should_install_ui_tools" == "true" ] && \
#   run-manual-postmessage-many-basic-setup the_first_ui_post_message

run-manual-postmessage-many-basic-setup zsh

# move back to original dir and update user
cd "$INITIAL_DIR"
send-message "init script complete, you should probably restart your terminal and/or your computer"
