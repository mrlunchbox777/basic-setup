# run install asbru function
run-install-asbru-basic-setup () {
  local should_install_asbru="false"
  if [ -z $(which asbru-cm) ]; then
    local should_install_asbru="true"
  fi
  if [[ "$should_install_azuredatastudio" == "true" ]]; then
    # pulled from https://www.asbru-cm.net/
    wget -qO- 'https://dl.cloudsmith.io/public/asbru-cm/release/cfg/setup/bash.deb.sh' | sudo -E bash
    sudo apt-get install asbru-cm 
  fi
}
