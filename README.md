# basic-setup

Basic box setup, it's fairly customizable using bash and will work on gui-based and headless systems. Open a pr if you want something added.

Currently only works on Windows(WIP) and Linux.

## Goal

We aren't here yet necessarily, this is the aim.

This will create a good basic setup for workstations. It should provide a pretty acceptable setup for a windows machine and debian derived linux machine. This is also supplies an ability to configure the applications/cron/etc to run on these systems.

## If You Are New

Run your OS Install

* [Linux](#install-using-bash)

After installing use the command `cs` and try the commands listed there. It contains links to documents, roadmaps, tutorials, and other cheatsheet commands. The developer roadmaps listed there can be very helpful, as can the suggestions on what they are used for.

## Installation

All of these will clone the repo and run the init script

### Install Using bash

Clones to `~/src/tools/basic-setup`

```bash
curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

#### Install Alias Only Using bash

This will still respect the .env, but will default everything that isn't alias related to false.

```bash
export BASICSETUPSHOULDDOALIASONLY="true" && curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
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

## Testing

You can run headless tests with the following

### Testing Headless

`docker run -it ubuntu`

then run

```bash
apt update && apt install curl sudo tzdata -y && export BASICSETUPSHOULDINSTALLUITOOLS="false" && echo "Europe/Zurich" > /etc/timezone && dpkg-reconfigure -f noniteractive tzdata && curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

### Testing GUI

You can run gui tests with [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
