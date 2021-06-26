# runs the powershell init script
# adapted from https://chocolatey.org/install

$currentDir = "$(Get-Location)"

New-Item ~/src/tools -ItemType Directory
Set-Location ~/src/tools

if ($IsWindows) {
  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please run in an admin terminal"
  }

  # eventually probably change this to winget - https://docs.microsoft.com/en-us/windows/package-manager/winget/
  # Adapted from https://chocolatey.org/install
  Set-ExecutionPolicy Bypass -Scope Process -Force;
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

  refresh-env

  choco install git -y
  choco install powershell-core --pre -y

  refresh-env
}

if ($IsLinux) {
  sudo apt-get update -y
  sudo apt-get install wget git bash -y
  sudo apt-get autoremove -y
}

if (-not (Test-Path "basic-setup")) {
  git clone https://github.com/mrlunchbox777/basic-setup
}

Set-Location basic-setup
Write-Output "current dir - $(Get-Location)"
if (-not $env:BasicSetupHasRunPwshInit) {
  pwsh -c ./install/init.ps1 | Tee-Object ./basic-setup-pwsh-output.log
  $env:BasicSetupHasRunPwshInit="$true"
}

if ($IsWindows -and ("$true" -eq "$env:ShouldInstall_wsl_ubuntu_2004")) {
  wsl wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
}

if ($IsLinux) {
  if (-not $env:BasicSetupHasRunShInit) {
    bash install/init.sh | tee basic-setup-sh-output.log
  } 
}

Set-Location "$currentDir"
