# runs the powershell init script
# adapted from https://chocolatey.org/install

$currentDir = "$(Get-Location)"

if ( -not (Test-Path ~/src/tools) ) {
  New-Item ~/src/tools -ItemType Directory
}
Set-Location ~/src/tools

$onWindows=(($IsWindows) -or ([System.String]::IsNullOrWhiteSpace($IsWindows) -and [System.String]::IsNullOrWhiteSpace($IsLinux)))
$onLinux=(-not $onWindows)

if ($onWindows) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please run in an admin terminal"
  }

  # eventually probably change this to winget - https://docs.microsoft.com/en-us/windows/package-manager/winget/
  # Adapted from https://chocolatey.org/install
  Set-ExecutionPolicy Bypass -Scope Process -Force;
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

  # https://stackoverflow.com/questions/46758437/how-to-refresh-the-environment-of-a-powershell-session-after-a-chocolatey-instal
  $env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."   
  Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
  refreshenv

  choco install git -y
  choco install powershell-core -y

  refreshenv
}

if ($onLinux) {
  sudo apt-get update -y
  sudo apt-get install wget git bash -y
  sudo apt-get autoremove -y
}

if (-not (Test-Path "basic-setup")) {
  git clone https://github.com/mrlunchbox777/basic-setup
}

Set-Location basic-setup
Write-Output "current dir - $(Get-Location)"
pwsh -c ./install/init.ps1 | Tee-Object ./basic-setup-pwsh-output.log

$shouldInstall_wsl_ubuntu_2004=[System.Environment]::GetEnvironmentVariable($SHOULDINSTALLWSLUBUNTU2004)
if([System.String]::IsNullOrWhiteSpace($shouldInstall_wsl_ubuntu_2004)) {$shouldInstall_wsl_ubuntu_2004="$true"}

if ($onWindows -and ("$true" -eq "$shouldInstall_wsl_ubuntu_2004")) {
  wsl wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
}

if ($onLinux) {
  bash install/init.sh | tee basic-setup-sh-output.log
}

Set-Location "$currentDir"
