# run install azcli function
run-install-azcli-basic-setup () {
	if [ -z $(which az) ]; then
		# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
		curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
	fi
}
