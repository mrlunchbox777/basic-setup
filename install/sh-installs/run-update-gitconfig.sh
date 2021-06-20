# run update gitconfig function
run-update-gitconfig-basic-setup () {
  if [ -z "$(grep 'path = .*basic-setup-gitconfig' ~/.gitconfig)" ]; then
    echo -e "\n[include]\n  path = \"$dir/../basic-setup-gitconfig\"" >> ~/.gitconfig
  else
    echo "Skipping update for .gitconfig..."
  fi
}
