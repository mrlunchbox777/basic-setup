if [[ "$(environment-os-type)" == "Mac" ]]; then
	/usr/bin/pbpaste "$@"
	exit $?
fi
xclip -selection clipboard -o "$@"
