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

  $initialDir=$(Get-Location).Path
  $sharedScriptsPath="../shared-scripts"
  if ( -not $(Test-Path "$sharedScriptsPath") ) {$sharedScriptsPath="./shared-scripts"}
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    $sharedScriptsPath=$(Get-ChildItem ./ "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
  }
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    $sharedScriptsPath=$(Get-ChildItem ~/ "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
  }
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    $sharedScriptsPath=$(Get-ChildItem / "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
  }
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    throw "error finding shared-scripts..."
  }
  
  foreach ($currentScript in $(Get-ChildItem "$sharedScriptsPath/powershell/")) { . $currentScript.FullName }
  $env:DIR="$PSScriptRoot"
  Set-Location "$env:DIR"

  $env:ShouldInstall_firefox="$(Get-EnvOrDefault "ShouldInstall_firefox" "$true")"
  $env:ShouldInstall_git="$(Get-EnvOrDefault "ShouldInstall_git" "$true")"
  $env:ShouldInstall_vim="$(Get-EnvOrDefault "ShouldInstall_vim" "$true")"
  $env:ShouldInstall_vscode="$(Get-EnvOrDefault "ShouldInstall_vscode" "$true")"
  $env:ShouldInstall_wsl_ubuntu_2004="$(Get-EnvOrDefault "ShouldInstall_wsl_ubuntu_2004" "$true")"

  # eventually probably change this to winget - https://docs.microsoft.com/en-us/windows/package-manager/winget/
  . powershell-installs/Install-Choco.ps1
  Install-ChocoBasicSetup

  . powershell-installs/Install-ChocoPackage.ps1
  Install-ManyChocoPackageBasicSetup `
    "chocogui" `
    "firefox" `
    "git" `
    "vim" `
    "vscode" `
    "wsl-ubuntu-2004"

  wsl wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh

  Set-Location "$initialDir"
}
