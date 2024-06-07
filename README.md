# basic-setup

* [install](#install-using-bash)
* [submit bug](https://github.com/mrlunchbox777/basic-setup/issues/new?template=bug.yaml)
* [find support](https://github.com/mrlunchbox777/basic-setup/blob/main/.github/SUPPORT.md)

Basic box setup, it's fairly customizable using bash and will work on gui-based and headless systems. Open a pr if you want something added.

## Goal

NOTE: This package will be moving to primarily [golang](https://go.dev/) instead of [bash](https://www.gnu.org/software/bash/) in the near future. This is primarily for portability, extensibility, and reusability.

This will create a good basic setup for development workstations on Linux/Mac/WSL, given a label (as used in ./resources/install/index.json '.packages[].labels').

NOTE: it's currently only regularly tested on Linux, but if you find issues on any os please [report them](https://github.com/mrlunchbox777/basic-setup/issues/new/choose).

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

Variable processing order is: environment file, environment variables, arguments (last wins).

### Manage Using .env

This is the best way to manage environment variables for this tool.

If you've already cloned the repo you can just copy the `.env`
```bash
mkdir -p ~/.basic-setup
cp template.env ~/.basic-setup/.env
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

### Golang

- `make test`
- `make coverage`

## Other Projects
As an orchestrator basic-setup relies heavily on external projects. When imported, they may or may not be specifically credited below or in the [bsctl README](/bsctl/README.md#other-projects); however, when code snippets are used, as much as possible, in no particular order, they will be listed with a link to their license below. Please report all missing attributions in an [issue](https://github.com/mrlunchbox777/basic-setup/issues/new?template=attribution.yaml)).

## Contact us

* [Open an issue](https://github.com/mrlunchbox777/basic-setup/issues/new/choose)
* [Open discussions](https://github.com/mrlunchbox777/basic-setup/discussions)
* [Join Discord](https://discord.gg/D68RzfvBhC)
