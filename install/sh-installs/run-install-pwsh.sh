# run install pwsh function
run-install-pwsh-basic-setup () {
  if [ -z $(which pwsh) ]; then
    # pulled from https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004
    # Update the list of packages
    sudo apt-get update
    # Install pre-requisite packages.
    sudo apt-get install -y wget apt-transport-https software-properties-common
    # Download the Microsoft repository GPG keys
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft.deb
    # Register the Microsoft repository GPG keys
    sudo dpkg -i packages-microsoft-prod.deb
    # Update the list of products
    sudo apt-get update
    # Enable the "universe" repositories
    sudo add-apt-repository universe
    # Install PowerShell
    sudo apt-get install -y powershell
    # Start PowerShell
    # pwsh
    # Remove package
    rm packages-microsoft.deb
  fi
}
