#! /usr/bin/env bash

dir="$(general-get-basic-setup-dir)"

function update_rc {
	local rc_file="$1"

	if [ ! -f "$HOME/$rc_file" ]; then
		touch "$HOME/$rc_file"
	fi

	if (($(grep '^\. .*alias/basic-setup.generalrc.sh"$' $HOME/$rc_file >/dev/null 2>&1; echo $?) != 0)); then
		local target_dir=$(readlink -f "$dir/alias/basic-setup.generalrc.sh")
		echo -e "\n. \"$target_dir\"" >> ~/$rc_file
	else
		echo "Update redundant. Skipping update for $rc_file..."
	fi
}

update_rc ".bashrc"
update_rc ".zshrc"
update_rc ".profile"
update_rc ".zprofile"
