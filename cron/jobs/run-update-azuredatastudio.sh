#!/bin/bash

shared_scripts_path="$(general-get-shared-scripts-dir)"
for basic_setup_generalrc_sh_f in $(ls -p "$shared_scripts_path/sh/" | grep -v /); do
  . "$shared_scripts_path/sh/$basic_setup_generalrc_sh_f"
done

source="${BASH_SOURCE[0]}"
run-get-source-and-dir "$source"
source="${rgsd[@]:0:1}"
dir="${rgsd[@]:1:1}"
orig_dir="$(pwd)"

cd "$dir/../../install"
dir="$dir/.."
BASICSETUPSHOULDFORCEUPDATEAZUREDATASTUDIO="true"
. ./sh-installs/run-install-azuredatastudio.sh
run-install-azuredatastudio-basic-setup
cd "$orig_dir"
