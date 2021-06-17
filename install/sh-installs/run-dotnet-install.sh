# run dotnet install function
run-dotnet-install-basic-setup () {
  if [ -z $(which dotnet) ]; then
    # pulled from https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu
    wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y apt-transport-https
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-5.0 aspnetcore-runtime-5.0
    rm packages-microsoft-prod.deb
  fi
}
