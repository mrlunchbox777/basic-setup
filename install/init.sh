#!/bin/bash
# Init script for worskstation

# track directories
initial_dir="$(pwd)"
shared_scripts_path="../shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path="./shared-scripts"
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src/tools -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find ./ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/src -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find $HOME/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find /home/ -type d -wholename "*basic-setup/shared-scripts")
[ ! -d "$shared_scripts_path" ] && shared_scripts_path=$(find / -type d -wholename "*basic-setup/shared-scripts")
if [ ! -d "$shared_scripts_path" ]; then
    echo -e "error finding shared-scripts..." >&2
    exit 1
fi
for basic_setup_init_sh_f in $(ls -p "$shared_scripts_path/sh/" | grep -v /); do
  source "$shared_scripts_path/sh/$basic_setup_init_sh_f";
done
source="${BASH_SOURCE[0]}"
sd="$(general-get-source-and-dir "$source")"
source="$(echo "$sd" | jq -r .source)"
dir="$(echo "$sd" | jq -r .dir)"
cd "$dir"

[ -f ../.env ] && \
  export $(cat ../.env | sed 's/#.*//g' | xargs)

# Set variables
## General variables
should_do_alias_only=${BASICSETUPSHOULDDOALIASONLY:-false}
negate_should_do_alias_only="true"
[ "$should_do_alias_only" == "true" ] && negate_should_do_alias_only="false"
should_skip_entertainment_apps=${SHOULDSKIPENTERTAINMENTAPPS:-true}
negate_should_skip_entertainment_apps="true"
[ "$should_skip_entertainment_apps" == "true" ] && negate_should_skip_entertainment_apps="false"
should_do_full_update=${BASICSETUPSHOULDDOFULLUPDATE:-$negate_should_do_alias_only}
should_do_submodule_update=${BASICSETUPSHOULDDOSUBMODULEUPDATE:-$negate_should_do_alias_only}
should_install_ui_tools=${BASICSETUPSHOULDINSTALLUITOOLS:-$negate_should_do_alias_only}
should_install_snap=${BASICSETUPSHOULDINSTALLSNAP:-$negate_should_do_alias_only}
should_add_github_key=${BASICSETUPSHOULDADDGITHUBKEY:-"true"}

## Apt variables
should_install_firefox=${BASICSETUPSHOULDINSTALLFIREFOX:-$negate_should_do_alias_only}
should_install_gimp=${BASICSETUPSHOULDINSTALLGIMP:-$negate_should_do_alias_only}
should_install_grpn=${BASICSETUPSHOULDINSTALLGRPN:-"false"}
should_install_kdeconnect=${BASICSETUPSHOULDINSTALLKDECONNECT:-$negate_should_do_alias_only}
should_install_kleopatra=${BASICSETUPSHOULDINSTALLKLEOPATRA:-$negate_should_do_alias_only}
should_install_libreoffice=${BASICSETUPSHOULDINSTALLLIBREOFFICE:-$negate_should_do_alias_only}
should_install_thunderbird=${BASICSETUPSHOULDINSTALLTHUNDERBIRD:-$negate_should_do_alias_only}
should_install_virtualbox=${BASICSETUPSHOULDINSTALLVIRTUALBOX:-$negate_should_do_alias_only}
should_install_vlc=${BASICSETUPSHOULDINSTALLVLC:-"false"}
should_install_wine=${BASICSETUPSHOULDINSTALLWINE:-$negate_should_do_alias_only}

should_install_bat=${BASICSETUPSHOULDINSTALLBAT:-$negate_should_do_alias_only}
should_install_calc=${BASICSETUPSHOULDINSTALLCALC:-$negate_should_do_alias_only}
should_install_curl=${BASICSETUPSHOULDINSTALLCURL:-$negate_should_do_alias_only}
should_install_gcc=${BASICSETUPSHOULDINSTALLGCC:-$negate_should_do_alias_only}
should_install_git=${BASICSETUPSHOULDINSTALLGIT:-$negate_should_do_alias_only}
should_install_golang=${BASICSETUPSHOULDINSTALLGOLANG:-$negate_should_do_alias_only}
should_install_gpg=${BASICSETUPSHOULDINSTALLGPG:-$negate_should_do_alias_only}
should_install_jq=${BASICSETUPSHOULDINSTALLJQ:-$negate_should_do_alias_only}
should_install_lynx=${BASICSETUPSHOULDINSTALLLYNX:-"false"}
should_install_make=${BASICSETUPSHOULDINSTALLMAKE:-$negate_should_do_alias_only}
should_install_openssh_client=${BASICSETUPSHOULDINSTALLOPENSSHCLIENT:-$negate_should_do_alias_only}
should_install_openjdk=${BASICSETUPSHOULDINSTALLOPENJDK:-$negate_should_do_alias_only}
should_install_python3=${BASICSETUPSHOULDINSTALLPYTHON3:-$negate_should_do_alias_only}
should_install_ranger=${BASICSETUPSHOULDINSTALLRANGER:-"false"}
should_install_terraform=${BASICSETUPSHOULDINSTALLTERRAFORM:-$negate_should_do_alias_only}
should_install_tldr=${BASICSETUPSHOULDINSTALLTLDR:-$negate_should_do_alias_only}
should_install_tmux=${BASICSETUPSHOULDINSTALLTMUX:-$negate_should_do_alias_only}
should_install_unattended_upgrades=${BASICSETUPSHOULDINSTALLUNATTENDEDUPGRADES:-$negate_should_do_alias_only}
should_install_uuid=${BASICSETUPSHOULDINSTALLUUID:-$negate_should_do_alias_only}
should_install_wget=${BASICSETUPSHOULDINSTALLWGET:-$negate_should_do_alias_only}
should_install_zsh=${BASICSETUPSHOULDINSTALLZSH:-$negate_should_do_alias_only}

## Snap variables
should_install_discord=${BASICSETUPSHOULDINSTALLDISCORD:-$should_skip_entertainment_apps}
should_install_remmina=${BASICSETUPSHOULDINSTALLREMMINA:-"false"}
should_install_slack=${BASICSETUPSHOULDINSTALLSLACK:-"false"}
should_install_spotify=${BASICSETUPSHOULDINSTALLSPOTIFY:-"false"}
should_install_teams=${BASICSETUPSHOULDINSTALLTEAMS:-"false"}

## Manual Install variables
should_install_asbru=${BASICSETUPSHOULDINSTALLASBRU:-$negate_should_do_alias_only}
should_install_azuredatastudio=${BASICSETUPSHOULDINSTALLAZUREDATASTUDIO:-"false"}
should_install_calibre=${BASICSETUPSHOULDINSTALLCALIBRE:-$negate_should_do_alias_only}
should_install_code=${BASICSETUPSHOULDINSTALLCODE:-$negate_should_do_alias_only}
should_install_lens=${BASICSETUPSHOULDINSTALLLENS:-"false"}
should_install_lutris=${BASICSETUPSHOULDINSTALLLUTRIS:-$should_skip_entertainment_apps}
should_install_steam=${BASICSETUPSHOULDINSTALLSTEAM:-$should_skip_entertainment_apps}
should_install_virtualboxextpack=${BASICSETUPSHOULDINSTALLVIRTUALBOXEXTPACK:-"false"}
should_install_zoom=${BASICSETUPSHOULDINSTALLZOOM:-"false"}

should_install_azcli=${BASICSETUPSHOULDINSTALLAZCLI:-$negate_should_do_alias_only}
should_install_dotnet=${BASICSETUPSHOULDINSTALLDOTNET:-$negate_should_do_alias_only}
should_install_helm=${BASICSETUPSHOULDINSTALLHELM:-$negate_should_do_alias_only}
should_install_k9s=${BASICSETUPSHOULDINSTALLK9S:-$negate_should_do_alias_only}
should_install_kind=${BASICSETUPSHOULDINSTALLKIND:-$negate_should_do_alias_only}
should_install_kubectl=${BASICSETUPSHOULDINSTALLKUBECTL:-$negate_should_do_alias_only}
should_install_mailutils=${BASICSETUPSHOULDINSTALLMAILUTILS:-$negate_should_do_alias_only}
should_install_minikube=${BASICSETUPSHOULDINSTALLMINIKUBE:-"false"}
should_install_nvm=${BASICSETUPSHOULDINSTALLNVM:-$negate_should_do_alias_only}
should_install_ohmyzsh=${BASICSETUPSHOULDINSTALLOHMYZSH:-$negate_should_do_alias_only}
should_install_postfix=${BASICSETUPSHOULDINSTALLPOSTFIX:-$negate_should_do_alias_only}
should_install_pwsh=${BASICSETUPSHOULDINSTALLPWSH:-$negate_should_do_alias_only}

## Config variables
should_update_code=${BASICSETUPSHOULDUPDATECODE:-$negate_should_do_alias_only}

should_update_alias=${BASICSETUPSHOULDUPDATEALIAS:-"true"}
should_update_batcat=${BASICSETUPSHOULDUPDATEBATCAT:-$negate_should_do_alias_only}
should_update_gitconfig=${BASICSETUPSHOULDUPDATEGITCONFIG:-"true"}
should_update_unattended_upgrades=${should_install_unattended_upgrades}

## CRON variables
# Check ../cron/run-add-cron.sh
# All variables will be set there as they need to be set when running that script
should_add_cron=${BASICSETUPSHOULDADDCRON:-$negate_should_do_alias_only}

## Postmessage variables
should_postmessage_zsh=${should_install_zsh}
should_postmessage_cron=${should_add_cron}

if [ "$should_add_github_key" == "true" ]; then
  ssh-keyscan -t rsa github.com | ssh-keygen -lf -
fi

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
    grpn \
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
  curl \
  gcc \
  git \
  golang \
  gpg \
  jq \
  lynx \
  make \
  openjdk \
  openssh-client \
  python3 \
  ranger \
  snap \
  terraform \
  tldr \
  tmux \
  unattended-upgrades \
  uuid \
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
      spotify \
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
    asbru \
    azuredatastudio \
    calibre \
    code \
    lens \
    lutris \
    steam \
    virtualboxextpack \
    zoom

run-manual-install-many-basic-setup \
  azcli \
  dotnet \
  helm \
  k9s \
  kind \
  kubectl \
  mailutils \
  minikube \
  nvm \
  ohmyzsh \
  postfix \
  pwsh

run-send-message "Starting Updates"
source ./sh-installs/run-manual-update.sh

[ "$should_install_ui_tools" == "true" ] && \
  run-manual-update-many-basic-setup \
    code

run-manual-update-many-basic-setup \
  "alias" \
  batcat \
  gitconfig \
  unattended-upgrades

if [ "$should_add_cron" == "true" ]; then
  run-send-message "Starting CRON"
  source ./../cron/run-add-cron.sh
else
  run-send-message "Skipping CRON"
fi

apt-get --fix-broken install -y

run-send-message "Starting Postmessages"
source ./sh-installs/run-manual-postmessage.sh

run-manual-postmessage-many-basic-setup \
  zsh

# move back to original dir and update user
cd "$initial_dir"
run-send-message "init script complete, you should probably restart your terminal and/or your computer"
