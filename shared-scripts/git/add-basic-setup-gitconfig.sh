if [ ! -f "$HOME/.gitconfig" ]; then
	touch "$HOME/.gitconfig"
fi

if [ -z "$(grep 'path = .*basic-setup.gitconfig"' ~/.gitconfig)" ]; then
	dir="$(general-get-basic-setup-dir)"
	target_dir=$(readlink -f "$dir/basic-setup.gitconfig")
	echo -e "\n[include]\n  path = \"$target_dir\"" >> ~/.gitconfig
else
	echo "Update redundant. Skipping update for .gitconfig..."
fi
