#! /usr/bin/env bash
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
should_do_alias_only=${BASIC_SETUP_SHOULD_DO_ALIAS_ONLY:-false}
should_add_github_key=${BASIC_SETUP_SHOULD_ADD_GITHUB_KEY:-"true"}

## Postmessage variables
should_postmessage_zsh=${should_install_zsh}

if [ "$should_add_github_key" == "true" ]; then
	ssh-keyscan -t rsa github.com | ssh-keygen -lf -
fi

git-submodule-update-all
environment-validation -i -c -v
git-add-basic-setup-gitconfig
basic-setup-add-general-rc

# move back to original dir and update user
cd "$initial_dir"
general-send-message "init script complete, consider changing your shell 'chsh -s \"\$(which zsh)\"', you should probably restart your terminal and/or your computer"
