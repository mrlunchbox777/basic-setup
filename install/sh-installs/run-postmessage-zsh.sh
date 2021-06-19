# run postmessage zsh function
run-postmessage-zsh-basic-setup () {
  # change the default shell to zsh
  if [[ ! "$SHELL" =~ .*"zsh" ]]; then
    send-message "To change to zsh run the following:" "" 'chsh -s $(which zsh)'
  fi
}
