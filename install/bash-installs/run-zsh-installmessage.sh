# run zsh install function
run-zsh-installmessage-basic-setup () {
  # change the default shell to zsh
  if [[ ! "$SHELL" =~ .*"zsh" ]]; then
    echo "********************************************************"
    echo "To change to zsh run the following:"
    echo ""
    echo 'chsh -s $(which zsh)'
    echo ""
    echo "********************************************************"
  fi
}
