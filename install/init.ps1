# Init script for worskstation

$initialDir=$(Get-Location).Path

$env:DIR="$PSScriptRoot"
Set-Location "$env:DIR"

$sharedScriptsPath="../shared-scripts"
if (-not (Test-Path "$sharedScriptsPath")) {$sharedScriptsPath="./shared-scripts"}
if (-not (Test-Path "$sharedScriptsPath")) {
  $sharedScriptsPath=$(Get-ChildItem ~/src/tools "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
}
if (-not (Test-Path "$sharedScriptsPath")) {
  $sharedScriptsPath=$(Get-ChildItem ./ "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
}
if (-not (Test-Path "$sharedScriptsPath")) {
  $sharedScriptsPath=$(Get-ChildItem ~/src "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
}
if (-not (Test-Path "$sharedScriptsPath")) {
  $sharedScriptsPath=$(Get-ChildItem ~/ "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
}
if (-not (Test-Path "$sharedScriptsPath")) {
  $sharedScriptsPath=$(Get-ChildItem / "*shared-scripts" -Recurse -Directory | Select-Object -ExpandProperty FullName)
}
if (-not (Test-Path "$sharedScriptsPath")) {
  throw "error finding shared-scripts..."
}
  
foreach ($currentScript in $(Get-ChildItem "$sharedScriptsPath/powershell/")) { . $currentScript.FullName }

$env:ShouldInstall_7zip:install="$(Get-EnvOrDefault "SHOULDINSTALL7ZIPINSTALL" "$true")"
$env:ShouldInstall_azure_functions_core_tools="$(Get-EnvOrDefault "SHOULDINSTALLAZUREFUNCTIONSCORETOOLS" "$true")"
$env:ShouldInstall_chocolatey="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEY" "$true")"
$env:ShouldInstall_chocolatey_core:extension="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEYCOREEXTENSION" "$true")"
$env:ShouldInstall_chocolatey_dotnetfx:extension="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEYDOTNETFXEXTENSION" "$true")"
$env:ShouldInstall_chocolatey_windowsupdate:extension="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOLATEYWINDOWSUPDATEEXTENSION" "$true")"
$env:ShouldInstall_chocogui="$(Get-EnvOrDefault "SHOULDINSTALLCHOCOGUI" "$true")"
$env:ShouldInstall_docker_desktop="$(Get-EnvOrDefault "SHOULDINSTALLDOCKERDESKTOP" "$true")"
$env:ShouldInstall_dotnetcore_sdk="$(Get-EnvOrDefault "SHOULDINSTALLDOTNETCORESDK" "$true")"
$env:ShouldInstall_filezilla="$(Get-EnvOrDefault "SHOULDINSTALLFILEZILLA" "$false")"
$env:ShouldInstall_firefox="$(Get-EnvOrDefault "SHOULDINSTALLFIREFOX" "$true")"
$env:ShouldInstall_git:install="$(Get-EnvOrDefault "SHOULDINSTALLGITINSTALL" "$true")"
$env:ShouldInstall_nuget:commandline="$(Get-EnvOrDefault "SHOULDINSTALLNUGETCOMMANDLINE" "$true")"
$env:ShouldInstall_nvm="$(Get-EnvOrDefault "SHOULDINSTALLNVM" "$true")"
$env:ShouldInstall_poshgit="$(Get-EnvOrDefault "SHOULDINSTALLPOSHGIT" "$true")"
$env:ShouldInstall_postman="$(Get-EnvOrDefault "SHOULDINSTALLPOSTMAN" "$true")"
$env:ShouldInstall_terraform="$(Get-EnvOrDefault "SHOULDINSTALLTERRAFORM" "$true")"
$env:ShouldInstall_vim="$(Get-EnvOrDefault "SHOULDINSTALLVIM" "$true")"
$env:ShouldInstall_vscode="$(Get-EnvOrDefault "SHOULDINSTALLVSCODE" "$true")"
$env:ShouldInstall_wsl_ubuntu_2004="$(Get-EnvOrDefault "SHOULDINSTALLWSLUBUNTU2004" "$true")"
$env:ShouldUpdateBasicSetupProfile="$(Get-EnvOrDefault "SHOULDUPDATEBASICSETUPPROFILE" "$true")"

Update-Help -UICulture en-US

if ($IsWindows) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please run in an admin terminal"
  }

  . powershell-installs/Install-ChocoPackage.ps1
  Install-ManyChocoPackageBasicSetup @(
    "7zip.install",
    "azure-functions-core-tools",
    "chocolatey",
    "chocolatey-core.extension",
    "chocolatey-dotnetfx.extension",
    "chocolatey-windowsupdate.extension",
    "chocogui",
    "docker-desktop",
    "dotnetcore-sdk",
    "filezilla",
    "firefox",
    "git.install",
    "nuget.commandline",
    "nvm",
    "poshgit",
    "postman",
    "terraform",
    "vim",
    "vscode",
    "wsl-ubuntu-2004"
  )
}

if ($IsLinux) {
  Write-Output "running for linux"
}

if ($true -eq "$env:ShouldUpdateBasicSetupProfile") {
  . "$env:DIR/powershell-installs/Update-Profile.ps1"
  Update-ProfileBasicSetup
}

Set-Location "$initialDir"
