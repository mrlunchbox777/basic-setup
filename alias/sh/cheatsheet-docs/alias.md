# Cheatsheet Alias

## Cheatsheet

* `alias cs=cheatsheet`
  * Get more info using `cs i` or `cs`

## Env-var

Saved for future use

## Docker

Please see the docker cheatsheet - `cs d`

## Git

* `alias g='git'`
* `gsmua()` - check with `how()`

## GPG

* `export GPG_TTY=$(tty)`
  * This just sets the GPG interactive terminal to an interactive terminal (useful for vscode & wsl)

## Import-nvm

* Adds the nvm dir to the path, adds nvm to the shell, and adds nvm bash completion
  * Pulled from [here](https://github.com/nvm-sh/nvm#git-install)

## K8s

Please see the kubernetes cheatsheet - `cs k`

## Network

* `my-public-ip()`
* `my-default-network-device()`
* `my-mac()`
* `my-default-route()`
* `my-local-ip()`

## Primary

* `alias guid='uuid'`
* `alias ll="ls -la"`
* `rgui()`
  * Restarts plasmashell (KDE)
* `cddev()` - check with `how()`
* `ffind()` - check with `how()`
* `dfind()` - check with `how()`
* `random()`
  * arg 1 - min value (defaults to `0`)
  * arg 2 - max value (default to `10`)
* `remove-containers()` - check with `how()`
* `full-docker-clear()` - check with `how()`
* `trim-end-of-string()` - check with `how()`
* `trim-whitespace()` - check with `how()`
* `find-files-ignore()` - check with `how()`
  * takes any number of args as ignore strings
* `count-lines-ignore()` - check with `how()`
  * takes any number of args as ignore strings
* `grepx()` - check with `how()`
  * grep | sed | xargs
  * arg 1 - regex for grep
  * arg 2 - command to run (defaults to `"code"`)
* `how()`
  * arg 1 - command to get source for
  * arg 2 - context before command (defaults to `3`)
  * arg 3 - bat language to use (defaults to `sh`)
  * arg 4 - context after command (defaults to `{{arg 2}} + 2`)
* `read-script()`
  * arg 1 - location of `script` output to read
* `diff-date()`
  * arg 1 - `date` minuend
  * arg 2 - `date` subrahend
* `is_on_wsl()` - check with `how()`
* `copy-kube-to-windows()`
  * arg 1 - Windows username (defaults to `$(whoami)`)
  * arg 2 - Invert target/source when `"true"`, i.e. copy from Windows to WSL (defaults to `"false"`)
