# run update alias function
run-update-alias-basic-setup () {
  local target_dir="$(readlink -f "$dir/../alias/basic-setup.generalrc.sh")"
  if [ ! -f "$HOME/.profile" ]; then
    touch "$HOME/.profile"
  fi

  if [ -z "$(grep 'source .*basic-setup.generalrc.sh' $HOME/.profile)" ]; then
    echo -e "\nsource \"$target_dir\"" >> $HOME/.profile
  else
    echo "Skipping update for .profile..."
  fi

  if [ ! -f "$HOME/.zprofile" ]; then
    touch "$HOME/.zprofile"
  fi

  if [ -z "$(grep 'source .*basic-setup.generalrc.sh' $HOME/.zprofile)" ]; then
    echo -e "\nsource \"$target_dir\"" >> $HOME/.zprofile
  else
    echo "Skipping update for .zprofile..."
  fi
}
