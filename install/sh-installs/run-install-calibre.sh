# run install calibre function
run-install-calibre-basic-setup () {
  if [ -z $(which calibre) ]; then
    # pulled from https://calibre-ebook.com/download_linux
    sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
  fi
}
