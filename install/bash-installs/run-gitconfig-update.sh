# run gitconfig update function
run-gitconfig-update-basic-setup () {
  if [ -z "$(grep 'path = .*gitconfig' ~/.gitconfig)" ]; then
    echo -e "\n[include]\n  path = \"$DIR/gitconfig\"" >> ~/.gitconfig
  else
    echo "Skipping update for .gitconfig..."
  fi
}
