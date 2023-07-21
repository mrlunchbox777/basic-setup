# run install calibre function
run-install-calibre-basic-setup () {
	local should_install_calibre="false"
	if [ -z $(which calibre) ]; then
		local should_install_calibre="true"
	else
		if [[ "$BASICSETUPSHOULDFORCEUPDATECALIBRE" == "true" ]]; then
			local should_install_calibre="true"
		fi
	fi
	if [[ "$should_install_calibre" == "true" ]]; then
		# pulled from https://calibre-ebook.com/download_linux
		sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
	fi
}
