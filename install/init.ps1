# Init script for worskstation

$initialDir=$(Get-Location).Path

$env:DIR="$PSScriptRoot"
Set-Location "$env:DIR"

if (Test-Path .env) {
  foreach ($line in $(Get-Content .env)) {
    if ([System.String]::IsNullOrWhiteSpace($line)) { continue; }
    if ($line.StartsWith("#")) { continue; }
    $envFileLineValues=$($line -split '=', 2)
    [System.Environment]::SetEnvironmentVariable("$($envFileLineValues[0])", "$($envFileLineValues[1])")
  }
}

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

# make sure these get-envordefault are actually pulling values and do proper defaults
$env:ShouldDoAliasOnly="$(Get-EnvOrDefault "BASICSETUPWINSHOULDDOALIASONLY" "$false")"
$env:ShouldInstall_7zip:install="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALL7ZIPINSTALL" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_azure_functions_core_tools="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLAZUREFUNCTIONSCORETOOLS" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_chocolatey="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLCHOCOLATEY" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_chocolatey_core:extension="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLCHOCOLATEYCOREEXTENSION" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_chocolatey_dotnetfx:extension="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLCHOCOLATEYDOTNETFXEXTENSION" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_chocolatey_windowsupdate:extension="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLCHOCOLATEYWINDOWSUPDATEEXTENSION" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_chocogui="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLCHOCOGUI" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_docker_desktop="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLDOCKERDESKTOP" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_dotnetcore_sdk="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLDOTNETCORESDK" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_filezilla="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLFILEZILLA" "$false")"
$env:ShouldInstall_firefox="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLFIREFOX" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_git:install="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLGITINSTALL" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_nuget:commandline="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLNUGETCOMMANDLINE" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_nvm="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLNVM" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_poshgit="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLPOSHGIT" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_postman="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLPOSTMAN" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_terraform="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLTERRAFORM" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_vim="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLVIM" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_vscode="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLVSCODE" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldInstall_wsl_ubuntu_2004="$(Get-EnvOrDefault "BASICSETUPWINSHOULDINSTALLWSLUBUNTU2004" "$(!$env:ShouldDoAliasOnly)")"
$env:ShouldUpdateBasicSetupProfile="$(Get-EnvOrDefault "BASICSETUPWINSHOULDUPDATEBASICSETUPPROFILE" "$true")"
$env:ShouldUpdateBasicSetupUpdateHelp="$(Get-EnvOrDefault "BASICSETUPWINSHOULDUPDATEBASICSETUPUPDATEHELP" "$(!$env:ShouldDoAliasOnly)")"

if ($true -eq "$env:ShouldUpdateBasicSetupUpdateHelp") {
  Update-Help -UICulture en-US
}

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
    "chocolateygui",
    # TODO if WSL is going to be installed only install this after WSL
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
    "wsl2",
    # TODO only install this when you are sure WSL is installed
    "wsl-ubuntu-2004"
  )

  # TODO add scheduled tasks - https://active-directory-wp.com/docs/Usage/How_to_add_a_cron_job_on_Windows/Scheduled_tasks_and_cron_jobs_on_Windows/index.html
}

if ($IsLinux) {
  Write-Output "running for linux"
}

if ($true -eq "$env:ShouldUpdateBasicSetupProfile") {
  . "$env:DIR/powershell-installs/Update-Profile.ps1"
  Update-ProfileBasicSetup
}

Set-Location "$initialDir"
