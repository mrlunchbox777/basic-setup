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

  # add a return early here

  $initialDir=$(Get-Location).Path
  $sharedScriptsPath="../shared-scripts"
  if ( -not $(Test-Path "$sharedScriptsPath") ) {$sharedScriptsPath="./shared-scripts"}
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    $sharedScriptsPath=$(Get-ChildItem ~/src/tools "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
  }
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    $sharedScriptsPath=$(Get-ChildItem ./ "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
  }
  if ( -not $(Test-Path "$sharedScriptsPath") ) {
    $sharedScriptsPath=$(Get-ChildItem ~/src "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
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

  $env:ShouldInstall_7zip.install="$(Get-EnvOrDefault "SHOULDINSTALL7ZIPINSTALL" "$true")"
  $env:ShouldInstall_azure_functions_core_tools="$(Get-EnvOrDefault "SHOULDINSTALLAZUREFUNCTIONSCORETOOLS" "$true")"
  $env:ShouldInstall_chocolatey="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEY" "$true")"
  $env:ShouldInstall_chocolatey_core.extension="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEYCOREEXTENSION" "$true")"
  $env:ShouldInstall_chocolatey_dotnetfx.extension="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEYDOTNETFXEXTENSION" "$true")"
  $env:ShouldInstall_chocolatey_windowsupdate.extension="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEYWINDOWSUPDATEEXTENSION" "$true")"
  $env:ShouldInstall_chocogui="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOGUI" "$true")"
  $env:ShouldInstall_docker_desktop="$(Get-EnvOrDefault "SHOULDINSTALLDOCKERDESKTOP" "$true")"
  $env:ShouldInstall_dotnetcore_sdk="$(Get-EnvOrDefault "SHOULDINSTALLDOTNETCORESDK" "$true")"
  $env:ShouldInstall_filezilla="$(Get-EnvOrDefault "SHOULDINSTALLFILEZILLA" "$false")"
  $env:ShouldInstall_firefox="$(Get-EnvOrDefault "SHOULDINSTALLFIREFOX" "$true")"
  $env:ShouldInstall_git.install="$(Get-EnvOrDefault "SHOULDINSTALLGITINSTALL" "$true")"
  $env:ShouldInstall_nuget.commandline="$(Get-EnvOrDefault "SHOULDINSTALLNUGETCOMMANDLINE" "$true")"
  $env:ShouldInstall_nvm="$(Get-EnvOrDefault "SHOULDINSTALLNVM" "$true")"
  $env:ShouldInstall_poshgit="$(Get-EnvOrDefault "SHOULDINSTALLPOSHGIT" "$true")"
  $env:ShouldInstall_postman="$(Get-EnvOrDefault "SHOULDINSTALLPOSTMAN" "$true")"
  $env:ShouldInstall_terraform="$(Get-EnvOrDefault "SHOULDINSTALLTERRAFORM" "$true")"
  $env:ShouldInstall_vim="$(Get-EnvOrDefault "SHOULDINSTALLVIM" "$true")"
  $env:ShouldInstall_vscode="$(Get-EnvOrDefault "SHOULDINSTALLVSCODE" "$true")"
  $env:ShouldInstall_wsl_ubuntu_2004="$(Get-EnvOrDefault "SHOULDINSTALLWSLUBUNTU2004" "$true")"

  # eventually probably change this to winget - https://docs.microsoft.com/en-us/windows/package-manager/winget/
  . powershell-installs/Install-Choco.ps1
  Install-ChocoBasicSetup

  . powershell-installs/Install-ChocoPackage.ps1
  Install-ManyChocoPackageBasicSetup `
    "7zip.install" `
    "azure-functions-core-tools" `
    "chocolatey" `
    "chocolatey-core.extension" `
    "chocolatey-dotnetfx.extension" `
    "chocolatey-windowsupdate.extension" `
    "chocogui" `
    "docker-desktop" `
    "dotnetcore-sdk" `
    "filezilla" `
    "firefox" `
    "git.install" `
    "nuget.commandline" `
    "nvm" `
    "poshgit" `
    "postman" `
    "terraform" `
    "vim" `
    "vscode" `
    "wsl-ubuntu-2004"

  wsl wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh

  Set-Location "$initialDir"
}
