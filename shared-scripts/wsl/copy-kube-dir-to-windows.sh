#! /usr/bin/env bash

is_on_wsl=$(is-on-wsl)
if [[ "$is_on_wsl" == "true" ]]; then
	windows_username="$1"
	if [ -z "$windows_username" ]; then
		windows_username="$(whoami)"
	fi
	target_dir="/mnt/c/Users/$windows_username"
	source_dir="~"
	if [[ "$2" == "true" ]]; then
		temp_dir="$target_dir"
		target_dir="$source_dir"
		source_dir="$temp_dir"
	fi
	if [ -d "$target_dir" ]; then
		if [ -d "$target_dir/.kube.bak/" ]; then
			echo "\"$target_dir/.kube.bak\" exists, would you like to remove it? [y/n]: " && read
			echo
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				rm -rf "$target_dir/.kube.bak"
			else
				echo "Didn't remove \"$target_dir/.kube.bak\", exiting..." >&2
				return 1
			fi
		fi
		if [ -d "$target_dir/.kube" ]; then
			mv "$target_dir/.kube" "$target_dir/.kube.bak"
		fi
		cp -r "$HOME/.kube/" "$target_dir/"
	else
		echo "\"$target_dir\" doesn't seem to exist" >&2
		return 1
	fi
else
	echo "This system doesn't seem to be on WSL" >&2
	return 1
fi
