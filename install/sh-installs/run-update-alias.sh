# run update alias function
run-single-update-alias() {
  if [ ! -f "$HOME/$1" ]; then
    touch "$HOME/$1"
  fi

  if [ -z "$(grep '\. \".*basic-setup\.generalrc\.sh' $HOME/$1)" ]; then
    echo -e "\n. \"$2\"" >> $HOME/$1
  else
    echo "Skipping update for $1..."
  fi
}

run-update-alias-basic-setup () {
  local target_dir="$(readlink -f "$dir/../alias/basic-setup.generalrc.sh")"

  run-single-update-alias ".profile" "$target_dir"
  run-single-update-alias ".zprofile" "$target_dir"
  run-single-update-alias ".bashrc" "$target_dir"
  run-single-update-alias ".zshrc" "$target_dir"
}
