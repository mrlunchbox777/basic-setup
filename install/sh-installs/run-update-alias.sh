# run update alias function
run-update-alias-basic-setup () {
  if [ ! -f "$HOME/.profile" ]; then
    touch "$HOME/.profile"
  fi

  if [ -z "$(grep 'source .*basic-setup.generalrc.sh' $HOME/.profile)" ]; then
    echo -e "\nsource \"$dir/../alias/basic-setup.generalrc.sh\"" >> $HOME/.profile
  else
    echo "Skipping update for .profile..."
  fi

  if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
  fi

  if [ -z "$(grep 'source .*basic-setup.generalrc.sh' $HOME/.zshrc)" ]; then
    echo -e "\nsource \"$dir/../alias/basic-setup.generalrc.sh\"" >> $HOME/.zshrc
  else
    echo "Skipping update for .zshrc..."
  fi
}
