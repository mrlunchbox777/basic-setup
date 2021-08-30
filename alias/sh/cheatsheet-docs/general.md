# General (Shared Scripts) Commands

## Command Info

*[basic command line tutorial](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview)*

*[developer roadmap](https://github.com/kamranahmedse/developer-roadmap)*

* tldr - get simple info on command
* man - get detailed info on command
* how - get source for command
* For basic info run `cs b` or `cs i`

## Commands

* `run-find-lines-dir-basic-setup()`
  * Finds the number of lines in a directory
  * No args
* `run-full-update-basic-setup()`
  * Runs an apt update, upgrade, and autoremove
  * No args
* `run-get-source-and-dir()`
  * Run with no args to get instructions
  * arg1 - source file
  * returns array of `("$source" "$dir")`
* `run-identify-shell-basic-setup()`
  * Identifies the current shell
    * Most effective on `sh`, `bash`, and `zsh`
  * No args
* `run-send-message()`
  * Echos a message using the basic setup format
  * args - messages to send
* `run-update-gitsubmodule-basic-setup()`
  * Updates submodules to latest
  * No args
