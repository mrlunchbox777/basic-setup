# run install lens function
run-install-lens-basic-setup () {
  local should_install_lens="false"
  if [ -z $(which lens) ]; then
    local should_install_lens="true"
  else
    if [[ "$BASICSETUPSHOULDFORCEUPDATELENS" == "true" ]]; then
      local should_install_lens="true"
    fi
  fi
  if [[ "$should_install_lens" == "true" ]]; then
    # https://k8slens.dev/
    local deb_url="https://api.k8slens.dev/binaries/Lens-5.2.7-latest.20211110.1.amd64.deb"
    curl -1fLsq "$deb_url" -o Lens.deb
    sudo dpkg --install Lens.deb
    rm Lens.deb
  fi
}
