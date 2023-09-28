# basic-setup

* [install](#install-using-bash)
* [submit bug](https://github.com/mrlunchbox777/basic-setup/issues/new?assignees=&labels=bug&template=bug.yaml&title=%5BBug%5D%3A+)
* [find support](https://github.com/mrlunchbox777/basic-setup/blob/main/.github/SUPPORT.md)

Basic box setup, it's fairly customizable using bash and will work on gui-based and headless systems. Open a pr if you want something added.

## Goal

This will create a good basic setup for development workstations on Linux/Mac/WSL, given a label (as used in ./resources/install/index.json '.packages[].labels').

NOTE: it's currently only regularly tested on Linux, but if you find issues on any os please [report them](https://github.com/mrlunchbox777/basic-setup/issues/new).

## If You Are New

Run your Shell Install

* [Bash](#install-using-bash)

After installing use the command `cs` and try the commands listed there. It contains links to documents, roadmaps, tutorials, and other cheatsheet commands. The developer roadmaps listed there can be very helpful, as can the suggestions on what they are used for.

## Installation

All of these will clone the repo and run the init script

### Install Using bash

Clones to `~/.basic-setup/basic-setup`

```bash
curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

## Environment Variables

### Manage Using .env

This is the best way to manage environment variables for this tool.

If you've already cloned the repo you can just copy the `.env`
```bash
cp template.env .env
```

Modify the `.env` file using the instructions listed there.

## Testing

You can run headless tests with the following

### Testing Headless

`docker run -it ubuntu`

then run

```bash
curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

### Testing GUI

You can run gui tests with [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

### Environment Specific Testing

There are various places in the code that need testing because they require a specific kind of setup (OS, architecture, etc).

You can find them with `grep --recursive '# TODO: NEEDS TESTING'`
