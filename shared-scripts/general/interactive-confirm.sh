#! /usr/bin/env bash

message="$1"
if [ -z "$message" ]; then
	message="Continue (y/n)?"
fi
while true; do
	read -p "$message" response
	case $response in
		[Yy]* ) echo true; break;;
		[Nn]* ) echo false; break;;
		* ) echo "Please answer yes or no.";;
	esac
done
