#! /usr/bin/env bash

target="$1"
if [ ! -d "$target" ]; then
	echo "Not a directory - $target" >&2
	exit 1
fi
items="$(ls -1aF "$target" | grep -v "^\.*/*$")"
for i in $items; do
	if [[ "$i" =~ /$ ]]; then
		general-ls-recursive "${target}${i}"
	else
		echo "${target}${i}"
	fi
done
