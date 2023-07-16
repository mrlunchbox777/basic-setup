#!/bin/bash

source="${BASH_SOURCE[0]}"
sd="$(general-get-source-and-dir "$source")"
source="$(echo "$sd" | jq -r .source)"
dir="$(echo "$sd" | jq -r .dir)"
orig_dir="$(pwd)"

cd "$dir/../../install"
dir="$dir/.."
BASICSETUPSHOULDFORCEUPDATELENS="true"
. ./sh-installs/run-install-lens.sh
run-install-lens-basic-setup
cd "$orig_dir"
