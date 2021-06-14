# run nvm install function
run-nvm-install-basic-setup () {
  if [ -z $(which nvm) ]; then
    # pulled from https://github.com/nvm-sh/nvm#installing-and-updating
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install node
    nvm use node
  fi
}
