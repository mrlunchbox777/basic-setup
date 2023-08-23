#! /usr/bin/env bash

# TODO: this is sloppy, maybe find a better way to do it?
if [ -d "/mnt/c/Windows" ]; then
	echo "true"
else
	echo "false"
fi
