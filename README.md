# basic-setup

Basic box setup, it's fairly customizable using bash/powershell and will work on gui-based and headless systems. Open a pr if you want something added.

Currently only works on Windows(WIP) and Linux.

## Goal

We aren't here yet necessarily, this is the aim.

This will create a good basic setup for workstations. It should provide a pretty acceptable setup for a windows machine and debian derived linux machine. This is also supplies an ability to configure the applications/cron/etc to run on these systems.

## Installation

All of these will clone the repo and run the init script

### Install Using bash

Clones to `~/src/tools/basic-setup`

```bash
wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

#### Install Alias Only Using bash

This will still respect the .env, but will default everything that isn't alias related to false.

```bash
export BASICSETUPSHOULDDOALIASONLY="true" && wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

### Install Using PowerShell

If Windows, runs powershell and choco installs.
To install WSL you'll need to run once, restart, and then run the command again.
If you are on a restricted computer, or have issues with WSL try `wsl --set-default-version 1` or to set your specific WSL Distro to version 1 with something like `wsl --set-version {{Distro Name}} 1` and you can get the distro name with `wsl -l -v`. You also need to make sure the [LXSS](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/cmdline/wsl-architectural-overview) service is running.

If Linux installs as expected.

**If Windows Run As Administrator**

```pwsh
$onWindows=(($IsWindows) -or ([System.String]::IsNullOrWhiteSpace($IsWindows) -and [System.String]::IsNullOrWhiteSpace($IsLinux))); if ($onWindows) {Set-ExecutionPolicy Bypass -Scope Process -Force;} [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.ps1'))
```

#### Install Alias Only Using PowerShell

This will still respect the .env, but will default everything that isn't alias related to false.

See [above](#install-using-powershell) for notes on OS variation installs.

**If Windows Run As Administrator**

```pwsh
$env:BASICSETUPWINSHOULDDOALIASONLY="$true"; BASICSETUPSHOULDDOALIASONLY="$true" ;$onWindows=(($IsWindows) -or ([System.String]::IsNullOrWhiteSpace($IsWindows) -and [System.String]::IsNullOrWhiteSpace($IsLinux))); if ($onWindows) {Set-ExecutionPolicy Bypass -Scope Process -Force;} [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.ps1'))
```

## Environment Variables

### Manage Using .env

This is the best way to manage environment variables for this tool.

If you've already cloned the repo you can just copy the `.env`
```bash
cp template.env .env
```

Modify the `.env` file using the instructions listed there.

## Headless Considerations

Make sure to, at a minimum, turn off ui tools.

### Turn off GUI Tools Using .env

Create a `.env` at `./` before running [Installation](#installation) as it'll be copied over as described in [Environment Variables](#environment-variables). In that `.env` have at least the below line.

```dotenv
BASICSETUPSHOULDINSTALLUITOOLS="false"
```

### Turn off GUI Tools Using bash

This will only last while the terminal is open, consider using the `.env`.

```bash
export BASICSETUPSHOULDINSTALLUITOOLS="false"
```

### Turn off GUI Tools Using powershell 

This will only last while the terminal is open, consider using the `.env`.

```powershell
$env:BASICSETUPSHOULDINSTALLUITOOLS = $false
```

## Testing

You can run headless tests with the following:

### Testing Headless

`docker run -it ubuntu`

then run

```apt update && apt install wget sudo tzdata -y && export BASICSETUPSHOULDINSTALLUITOOLS="false" && echo "Europe/Zurich" > /etc/timezone && dpkg-reconfigure -f noniteractive tzdata && wget -qO- https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh```

### Testing GUI

You can run gui tests with [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
