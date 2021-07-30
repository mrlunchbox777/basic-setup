# basic-setup

Basic box setup, it's fairly customizable using bash/powershell and will work on gui-based and headless systems. Open a pr if you want something added.

Currently only works on Windows(WIP) and Linux.

## Installation

All of these will clone the repo and run the init script

### Install Using bash

Clones to ~/src/tools/basic-setup

```bash
wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

### Install Using PowerShell

If Windows, runs powershell and choco installs.
To install WSL you'll need to run once, restart, and then run the command again.
If you are on a restricted computer, or have issues with WSL try `wsl --set-default-version 1` or to set your specific WSL Distro to version 1 with something like `wsl --set-version {{Distro Name}} 1` and you can get the distro name with `wsl -l -v`

If Linux installs as expected.

**If Windows Run As Administrator**

```pwsh
$onWindows=(($IsWindows) -or ([System.String]::IsNullOrWhiteSpace($IsWindows) -and [System.String]::IsNullOrWhiteSpace($IsLinux))); if ($onWindows) {Set-ExecutionPolicy Bypass -Scope Process -Force;} [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.ps1'))
```

## Headless Considerations

Make sure to, at a minimum, turn off ui tools.

### Turn off GUI Tools Using .env

This only works if you clone the repo first. It is also designed for use with sh/bash/zsh.

```bash
cp template.env .env
```
Modify the `.env` file using the instructions listed there.

### Turn off GUI Tools Using bash

```bash
export BASICSETUPSHOULDINSTALLUITOOLS="false"
```

### Turn off GUI Tools Using bash

```pwsh
$env:BASICSETUPSHOULDINSTALLUITOOLS = $false
```

## Goal

We aren't here yet necessarily, this is the aim.

This will create a good basic setup for workstations. It should provide a pretty acceptable setup for a windows machine and debian derived linux machine. This is also supplies an ability to configure the applications/cron/etc to run on these systems.
