# run install lutris function
run-install-lutris-basic-setup () {
	if [ -z $(which lutris) ]; then
		# pulled from https://lutris.net/downloads/
		sudo add-apt-repository ppa:lutris-team/lutris
		sudo apt-get update
		sudo apt-get install -y lutris
	fi
}
