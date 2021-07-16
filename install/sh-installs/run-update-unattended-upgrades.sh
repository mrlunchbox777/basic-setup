# run update unattended-upgrades function
run-update-unattended-upgrades-basic-setup () {
  # https://help.ubuntu.com/community/AutomaticSecurityUpdates
  echo "update unattended upgrades"
  # TODO find a way to only update the config if it hasn't already been updated
  # if [ -z $(which unattended-upgrades) ]; then
  #   sudo dpkg-reconfigure --priority=low unattended-upgrades
  # fi
}
