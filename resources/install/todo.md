# TODO: more curl installs

## Add the curl commands that are most important

* k9s
* kpt - https://kpt.dev/installation/kpt-cli
* mattermost
* nvm
* ohmyzsh

## Add repo commands

we should support some standard add repo commands for the package managers (this will require adding some stuff to schema)

docker.io - https://docs.docker.com/engine/install/

## other curls that are nice to have

* discord
* gsed (for mac)
* lens
* slack
* teams
* todoist
* zoom

## other curls that are less important

* asbru
* azcli
* calibre
* golang
* kdeconnect
* lutris
* openjdk
* pwsh
* spotify
* steam
* vlc
* virtualbox as curl (specifically for redhat)...

### Notes

for both coreutils and gsed, you need to add them to path to override the defaults

PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
