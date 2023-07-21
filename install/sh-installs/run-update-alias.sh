# run update alias function
run-single-update-alias-basic-setup() {
	if [ ! -f "$HOME/$1" ]; then
		touch "$HOME/$1"
	fi

	if [ -z "$(grep '\. \".*basic-setup\.generalrc\.sh' $HOME/$1)" ]; then
		echo -e "\n. \"$2\"" >> $HOME/$1
	else
		echo "Update redundant. Skipping update for $1..."
	fi
}

run-update-alias-basic-setup () {
	local target_dir="$(readlink -f "$dir/../alias/basic-setup.generalrc.sh")"

	run-single-update-alias-basic-setup ".profile" "$target_dir"
	run-single-update-alias-basic-setup ".zprofile" "$target_dir"
	run-single-update-alias-basic-setup ".bashrc" "$target_dir"
	run-single-update-alias-basic-setup ".zshrc" "$target_dir"
}
