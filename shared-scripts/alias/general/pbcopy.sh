if [[ "$(environment-os-type)" == "Mac" ]]; then
	/usr/bin/pbcopy $@
	exit $?
fi
xclip -selection clipboard $@
