#!/bin/bash

source="${BASH_SOURCE[0]}"
sd="$(general-get-source-and-dir "$source")"
source="$(echo "$sd" | jq -r .source)"
dir="$(echo "$sd" | jq -r .dir)"
orig_dir="$(pwd)"

cd "$dir/../../install"
dir="$dir/.."
BASICSETUPSHOULDFORCEUPDATECALIBRE="true"
. ./sh-installs/run-install-calibre.sh
run-install-calibre-basic-setup
cd "$orig_dir"
