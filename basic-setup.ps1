# runs the powershell init script
# adapted from https://chocolatey.org/install

  # need a git clone here (how to require git before choco....)

if ($IsWindows) {Set-ExecutionPolicy Bypass -Scope Process -Force;} [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/install/init.ps1'))# clones and installs the basic setup
