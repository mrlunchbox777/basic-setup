#! /usr/bin/env bash

# TODO: allow searching from different directories and default the search from the current directory
sudo find ./ -type d -iname "$@"
