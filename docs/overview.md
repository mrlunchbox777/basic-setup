# Overview

This is a library of helpful scripts for a development, operations, or administration environment. It can be installed with a single line of code, and when installed will install a litany of helpful tools, scripts, and aliases.

## Installation

Simply run

Clones to `~/.basic-setup/basic-setup`

```bash
curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh
```

## General

Most scripts have a `-h` option to offer help.

Since most of the scripts are added to `PATH` by default autocomplete can be used to find scripts, and they can be used in subshells/watch.

### List Scripts

You can list all of the available scripts with `basic-setup-list-scripts`.

`basic-setup-list-scripts` also has `-g` which is a built in grep option to make filtering a bit easier.

### How

`how` is like `which`, but gives more context, follows links, and if it's a script prints the script.

### Cheatsheet

`cs` is a command that prints cheat sheets for the given parametersm run with -h to list the possible parameters.

### Environment Validation

`environment-validation` is a script that will ensure you have good tooling given labels. You can find the tooling that it will install by running `jq . "$(general-get-basic-setup-dir)/resources/install/index.json"`

Run it with `-h` for more information, particularly pay attention to labels.

## Big Bang Support

There are several scripts to support big-bang specifically. These will be removed as bbctl implements their functionality.

## Update

This script automatically check for updates for itself and it's dependencies daily provided you run scripts that it provides.
