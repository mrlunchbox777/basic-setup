#!/bin/bash
# Init script for worskstation
#if haven't run init.sh
#init.sh

# track directories
initial_dir="$(pwd)"
shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="./shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src/tools -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
    echo -e "error finding shared-scripts..." >&2
    exit 1
fi
for basic_setup_init_sh_f in $(ls "$shared_scripts_path/sh/"); do source "$shared_scripts_path/sh/$basic_setup_init_sh_f"; done
source="${BASH_SOURCE[0]}"
run-get-source-and-dir "$source"
source="${rgsd[@]:0:1}"
dir="${rgsd[@]:1:1}"
cd "$dir"

if [ -f "../.env" ]; then
  source ../.env
fi

# Set variables
## General variables
should_do_full_update=${BASICSETUPSHOULDDOFULLUPDATE:-true}
should_do_submodule_update=${BASICSETUPSHOULDDOSUBMODULEUPDATE:-true}
should_install_ui_tools=${BASICSETUPSHOULDINSTALLUITOOLS:-true}
should_install_snap=${BASICSETUPSHOULDINSTALLSNAP:-true}

## Apt variables
should_install_firefox=${BASICSETUPSHOULDINSTALLFIREFOX:-true}
should_install_gimp=${BASICSETUPSHOULDINSTALLGIMP:-true}
should_install_kdeconnect=${BASICSETUPSHOULDINSTALLKDECONNECT:-true}
should_install_kleopatra=${BASICSETUPSHOULDINSTALLKLEOPATRA:-true}
should_install_libreoffice=${BASICSETUPSHOULDINSTALLLIBREOFFICE:-true}
should_install_thunderbird=${BASICSETUPSHOULDINSTALLTHUNDERBIRD:-true}
should_install_virtualbox=${BASICSETUPSHOULDINSTALLVIRTUALBOX:-true}
should_install_vlc=${BASICSETUPSHOULDINSTALLVLC:-true}
should_install_wine=${BASICSETUPSHOULDINSTALLWINE:-true}

should_install_azcli=${BASICSETUPSHOULDINSTALLAZCLI:-true}
should_install_bat=${BASICSETUPSHOULDINSTALLBAT:-true}
should_install_calc=${BASICSETUPSHOULDINSTALLCALC:-true}
should_install_gcc=${BASICSETUPSHOULDINSTALLGCC:-true}
should_install_git=${BASICSETUPSHOULDINSTALLGIT:-true}
should_install_gpg=${BASICSETUPSHOULDINSTALLGPG:-true}
should_install_jq=${BASICSETUPSHOULDINSTALLJQ:-true}
should_install_lynx=${BASICSETUPSHOULDINSTALLLYNX:-true}
should_install_openssh_client=${BASICSETUPSHOULDINSTALLOPENSSHCLIENT:-true}
should_install_openjdk=${BASICSETUPSHOULDINSTALLOPENJDK:-true}
should_install_python3=${BASICSETUPSHOULDINSTALLPYTHON3:-true}
should_install_terraform=${BASICSETUPSHOULDINSTALLTERRAFORM:-true}
should_install_tldr=${BASICSETUPSHOULDINSTALLTLDR:-true}
should_install_tmux=${BASICSETUPSHOULDINSTALLTMUX:-true}
should_install_wget=${BASICSETUPSHOULDINSTALLWGET:-true}
should_install_zsh=${BASICSETUPSHOULDINSTALLZSH:-true}

## Snap variables
should_install_discord=${BASICSETUPSHOULDINSTALLDISCORD:-true}
should_install_remmina=${BASICSETUPSHOULDINSTALLREMMINA:-true}
should_install_slack=${BASICSETUPSHOULDINSTALLSLACK:-true}
should_install_teams=${BASICSETUPSHOULDINSTALLTEAMS:-true}

## Manual Install variables
should_install_code=${BASICSETUPSHOULDINSTALLCODE:-true}
should_install_virtualboxextpack=${BASICSETUPSHOULDINSTALLVIRTUALBOXEXTPACK:-true}
should_install_zoom=${BASICSETUPSHOULDINSTALLZOOM:-true}

should_install_dotnet=${BASICSETUPSHOULDINSTALLDOTNET:-true}
should_install_nvm=${BASICSETUPSHOULDINSTALLNVM:-true}
should_install_ohmyzsh=${BASICSETUPSHOULDINSTALLOHMYZSH:-true}
should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-true}

## Postmessage variables
should_postmessage_zsh=${should_install_zsh}

## Config variables
should_update_code=${BASICSETUPSHOULDUPDATECODE:-true}

should_update_alias=${BASICSETUPSHOULDUPDATEALIAS:-true}
should_update_batcat=${BASICSETUPSHOULDUPDATEBATCAT:-true}
should_update_gitconfig=${BASICSETUPSHOULDUPDATEGITCONFIG:-true}

if [ "$should_do_full_update" == "true" ]; then
  run-send-message "Starting Full Update"
  run-full-update-basic-setup
else
  run-send-message "Skipping Full Update"
fi

run-send-message "Starting apt Installs"
source sh-installs/run-manual-install-apt.sh

[ $should_install_ui_tools == "true" ] && \
  run-manual-install-apt-many-basic-setup \
    firefox \
    gimp \
    kdeconnect \
    kleopatra \
    libreoffice \
    thunderbird \
    virtualbox \
    vlc \
    wine

run-manual-install-apt-many-basic-setup \
  bat \
  calc \
  gcc \
  git \
  gpg \
  jq \
  lynx \
  openjdk \
  openssh-client \
  python3 \
  snap \
  terraform \
  tldr \
  tmux \
  wget \
  zsh

if [ $should_install_snap == "true" ]; then
  run-send-message "Starting snap Installs"
  source sh-installs/run-manual-install-snap.sh

  [ $should_install_ui_tools == "true" ] && \
    run-manual-install-snap-many-basic-setup \
      discord \
      remmina \
      slack \
      teams
else
  run-send-message "Skipping snap Installs"
fi

run-send-message "Starting git submodule update"
[ "$should_do_submodule_update" == "true" ] && \
  run-update-gitsubmodule-basic-setup

run-send-message "Starting Manual Installs"
source ./sh-installs/run-manual-install.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-install-many-basic-setup \
    code \
    virtualboxextpack \
    zoom

run-manual-install-many-basic-setup \
  azcli \
  dotnet \
  nvm \
  ohmyzsh \
  pwsh

run-send-message "Starting Updates"
source ./sh-installs/run-manual-update.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-update-many-basic-setup \
    code

run-manual-update-many-basic-setup \
  "alias" \
  batcat \
  gitconfig

# TODO: consider adding the powerlevel 10k theme to oh my zsh -
#   https://github.com/romkatv/powerlevel10k#installation

run-send-message "Starting Postmessages"
source ./sh-installs/run-manual-postmessage.sh

run-manual-postmessage-many-basic-setup \
  zsh

# move back to original dir and update user
cd "$initial_dir"
run-send-message "init script complete, you should probably restart your terminal and/or your computer"
