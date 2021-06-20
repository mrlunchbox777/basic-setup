#!/bin/bash
# Init script for worskstation

# track directories
initial_dir="$(pwd)"
shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="./shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
    echo -e "error finding shared-scripts..." >&2
    exit 1
fi
for f in $(ls "$shared_scripts_path/sh/"); do source "$shared_scripts_path/sh/$f"; done
source="${BASH_SOURCE[0]}"
run-get-source-and-dir "$source"
source="${rgsd[0]}"
dir="${rgsd[1]}"
cd "$dir"

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

[ "$should_do_full_update" == "true" ] && \
  run-full-update-basic-setup

run-send-message "Starting apt Installs"
source sh-installs/run-manual-install-apt.sh

[ $should_install_ui_tools == "true" ] && \
  run-manual-install-apt-many-basic-setup firefox kleopatra

run-manual-install-apt-many-basic-setup bat calc git gpg jq openssh-client terraform tmux wget zsh

run-send-message "Starting git submodule update"
[ "$should_do_submodule_update" == "true" ] && \
  run-update-gitsubmodule-basic-setup

run-send-message "Starting Manual Installs"
source ./sh-installs/run-manual-install.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-install-many-basic-setup code

run-manual-install-many-basic-setup dotnet nvm ohmyzsh pwsh

run-send-message "Starting Config Updates"
source ./sh-installs/run-manual-update.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-update-many-basic-setup code

run-manual-update-many-basic-setup alias batcat gitconfig

# TODO: consider adding the powerlevel 10k theme to oh my zsh -
#   https://github.com/romkatv/powerlevel10k#installation

## Post-install messages
run-send-message "Starting Postmessages"
source ./sh-installs/run-manual-postmessage.sh

# [ "$should_install_ui_tools" == "true" ] && \
#   run-manual-postmessage-many-basic-setup the_first_ui_post_message

run-manual-postmessage-many-basic-setup zsh

# move back to original dir and update user
cd "$initial_dir"
run-send-message "init script complete, you should probably restart your terminal and/or your computer"
