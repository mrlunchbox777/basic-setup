# run install steam function
run-install-steam-basic-setup () {
	if [ -z $(which steam) ]; then
		sudo add-apt-repository multiverse
		sudo apt-get update
		sudo apt-get install -y steam
	fi
}
