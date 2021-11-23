# run install azuredatastudio function
run-install-azuredatastudio-basic-setup () {
  local should_install_azuredatastudio="false"
  if [ -z $(which azuredatastudio) ]; then
    local should_install_azuredatastudio="true"
  else
    if [[ "$BASICSETUPSHOULDFORCEUPDATEAZUREDATASTUDIO" == "true" ]]; then
      local should_install_azuredatastudio="true"
    fi
  fi
  if [[ "$should_install_azuredatastudio" == "true" ]]; then
    # pulled from https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15#linux-installationttps://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
    curl -1fLsq https://go.microsoft.com/fwlink/?linkid=2168339 -o azure_data_studio.deb
    sudo dpkg -i ./azure_data_studio.deb
    rm azure_data_studio.deb
    sudo apt-get install libunwind8
    sudo apt-get install -f
  fi
}
