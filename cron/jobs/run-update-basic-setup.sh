#!/bin/bash

source="${BASH_SOURCE[0]}"
sd="$(general-get-source-and-dir "$source")"
source="$(echo "$sd" | jq -r .source)"
dir="$(echo "$sd" | jq -r .dir)"
orig_dir="$(pwd)"

cd "$dir"
stash_name="$(uuid)"
orig_branch_name="$(git rev-parse --abbrev-ref HEAD)"
git stash push -m "$stash_name"
git checkout main
git pull
git checkout "$orig_branch_name"
git stash list | grep "$stash_name" && git stash pop
cd "$orig_dir"
