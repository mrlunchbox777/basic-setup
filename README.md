# basic-setup

Basic box setup, it's fairly customizable using powershell and will work on gui-based and headless systems. Open a pr if you want something added.

## Installation

All of these will clone the repo and run the init script

### Install Using bash

Clones to ~/src/tools/basic-setup

```bash
wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | bash
```

### Install Using PowerShell

Installs wsl and tries to run from there.

This command is pulled from [the `basic-setup.ps1`](https://github.com/mrlunchbox777/basic-setup/main/basic-setup.ps1)

```pwsh
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/init.ps1'))# clones and installs the basic setup
```
