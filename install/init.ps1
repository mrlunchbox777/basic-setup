# Init script for worskstation

# Powershell on Linux
if ($IsLinux) {
  # ensure tooling
  sudo apt-get update -y
  sudo apt-get install wget -y
  sudo apt-get autoremove -y

  # run init
  sh -c "wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh"
}

# Powershell on Windows
if ($IsWindows) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please run in an admin terminal"
  }

  . powershell-installs/Install-Choco.ps1
  Install-ChocoBasicSetup

  # wsl --install -d ubuntu
  # TODO: all of this

  # maybe install choco and other stuff
    # eventually probably change this to winget - https://docs.microsoft.com/en-us/windows/package-manager/winget/

  # run the init.sh in wsl
}
