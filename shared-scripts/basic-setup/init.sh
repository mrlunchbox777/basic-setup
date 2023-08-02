#! usr/bin/env bash
# Init script for worskstation

# track directories
initial_dir="$(pwd)"
source="${BASH_SOURCE[0]}"
if (( $(command -v general-get-source-and-dir >/dev/null 2>&1; echo $?) != 0 )); then
	echo "general-get-source-and-dir not found, please ensure \$basic_setup_directory/shared-scripts/bin is in your path before running..." >&2
	exit 1
fi
sd="$(general-get-source-and-dir "$source")"
source="$(echo "$sd" | jq -r .source)"
dir="$(echo "$sd" | jq -r .dir)"
cd "$dir"

[ -f ../../.env ] && \
	export $(cat ../../.env | sed 's/#.*//g' | xargs)

# Set variables
## General variables
should_do_alias_only=${BASICSETUPSHOULDDOALIASONLY:-false}
should_do_full_update=${BASICSETUPSHOULDDOFULLUPDATE:-$negate_should_do_alias_only}
should_do_submodule_update=${BASICSETUPSHOULDDOSUBMODULEUPDATE:-$negate_should_do_alias_only}
should_add_github_key=${BASICSETUPSHOULDADDGITHUBKEY:-"true"}

## Config variables
should_update_code=${BASICSETUPSHOULDUPDATECODE:-$negate_should_do_alias_only}

## Postmessage variables
should_postmessage_zsh=${should_install_zsh}

if [ "$should_add_github_key" == "true" ]; then
	ssh-keyscan -t rsa github.com | ssh-keygen -lf -
fi

if [ "$should_do_full_update" == "true" ]; then
	general-send-message "Starting Full Update"
	run-full-update-basic-setup
else
	general-send-message "Skipping Full Update"
fi

general-send-message "Starting apt Installs"
source sh-installs/run-manual-install-apt.sh


general-send-message "Starting Postmessages"
source ./sh-installs/run-manual-postmessage.sh

run-manual-postmessage-many-basic-setup \
	zsh

# move back to original dir and update user
cd "$initial_dir"
general-send-message "init script complete, you should probably restart your terminal and/or your computer"
