# General (Shared Scripts) Commands

## Command Info

*[basic command line tutorial](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview)*

*[developer roadmap](https://github.com/kamranahmedse/developer-roadmap)*

* tldr - get simple info on command
* man - get detailed info on command
* how - get source for command
* For basic info run `cs b` or `cs i`

## Commands

* `sd="$(get-sandd "$source")"`
  * Run with no args to get instructions, currently only can handle being run from scripts
  * arg1 - source file
  * returns json of `{ "source": "$source", "dir": "$dir"}`
    * source="$(echo "$sd" | jq -r .source)"
    * dir="$(echo "$sd" | jq -r .dir)"
* `identify-shell`
  * Identifies the current shell
    * Most effective on `sh`, `bash`, and `zsh`
  * No args
* `general-send-message()`
  * Echos a message using the basic setup format
  * args - messages to send
* `git-submodule-update-all()`
  * Updates submodules to latest
  * No args
