# run install azuredatastudio function
run-install-azuredatastudio-basic-setup () {
  if [ -z $(which azuredatastudio) ]; then
    # pulled from https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15#linux-installationttps://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions
    wget -q https://go.microsoft.com/fwlink/?linkid=2168339 -O azure_data_studio.deb
    sudo dpkg -i ./azure_data_studio.deb
    rm azure_data_studio.deb
    sudo apt-get install libunwind8
    sudo apt-get install -f
  fi
}
