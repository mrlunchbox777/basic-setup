# run install zoom function
run-install-zoom-basic-setup () {
  if [ -z $(which zoom) ]; then
    # https://support.zoom.us/hc/en-us/articles/204206269-Installing-or-updating-Zoom-on-Linux
    curl -1fLsq https://zoom.us/client/latest/zoom_amd64.deb -O zoom.deb
    sudo dpkg -i ./zoom.deb
    rm zoom.deb
    sudo apt-get install -f
  fi
}
