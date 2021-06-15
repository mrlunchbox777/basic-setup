# basic-setup

Basic box setup, it's fairly customizable using bash/powershell and will work on gui-based and headless systems. Open a pr if you want something added.

Currently only works on Windows and Linux.

## Installation

All of these will clone the repo and run the init script

### Install Using bash

Clones to ~/src/tools/basic-setup

```bash
wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

### Install Using PowerShell

If Windows Installs wsl and tries to run from there. If Linux installs as expected.

```pwsh
if ($IsWindows) {Set-ExecutionPolicy Bypass -Scope Process -Force;} [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.ps1'))# clones and installs the basic setup
```
