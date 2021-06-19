# run update batcat function
run-update-batcat-basic-setup () {
  if [ -z $(which bat) ]; then
    if [ -z $(which batcat) ]; then
      ln -s "$(which batcat)" "$(dirname $(which batcat))/bat"
    else
      echo "Skipping update for batcat, batcat doesn't exist..."
    fi
  else
    echo "Skipping update for batcat, already exits..."
  fi
}
