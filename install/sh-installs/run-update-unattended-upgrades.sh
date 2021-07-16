# run update unattended-upgrades function
run-update-unattended-upgrades-basic-setup () {
  # https://help.ubuntu.com/community/AutomaticSecurityUpdates
  if [ ! -z $(which unattended-upgrades) ]; then
    echo "update unattended upgrades"
    sudo dpkg-reconfigure --priority=low unattended-upgrades
  fi
}
