# run update sh function
run-update-sh-basic-setup () {
  if [ -z "$(grep 'source .*basic-setup.generalrc.sh' ~/.profile)" ]; then
    echo -e "\nsource \"$dir/../alias/basic-setup.generalrc.sh\"" >> ~/.profile
  else
    echo "Skipping update for .profile..."
  fi

  if [ ! -f "~/.zshrc" ]; then
    touch "~/.zshrc"
  fi

  if [ -z "$(grep 'source .*basic-setup.generalrc.sh' ~/.zshrc)" ]; then
    echo -e "\nsource \"$dir/../alias/basic-setup.generalrc.sh\"" >> ~/.zshrc
  else
    echo "Skipping update for .zshrc..."
  fi
}
