# run install lens function
run-install-lens-basic-setup () {
  if [ -z $(which lens) ]; then
    # https://k8slens.dev/
    local deb_url="https://api.k8slens.dev/binaries/Lens-5.1.2-latest.20210719.1.amd64.deb"
    wget "$deb_url" -O Lens.deb
    sudo dpkg --install Lens.deb
    rm Lens.deb
  fi
}
