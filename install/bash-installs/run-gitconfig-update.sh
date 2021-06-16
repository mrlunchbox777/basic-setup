# run gitconfig update function
run-gitconfig-update-basic-setup () {
  if [ -z "$(grep 'path = .*basic-setup-gitconfig' ~/.gitconfig)" ]; then
    echo -e "\n[include]\n  path = \"$DIR/basic-setup-gitconfig\"" >> ~/.gitconfig
  else
    echo "Skipping update for .gitconfig..."
  fi
}
