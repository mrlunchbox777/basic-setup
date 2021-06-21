# Install-ChocoBasicSetup
function Install-ChocoBasicSetup() {
  # Adapted from https://chocolatey.org/install
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

  refresh-env
}
