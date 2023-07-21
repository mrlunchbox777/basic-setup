# run install kubectl function
run-install-kubectl-basic-setup () {
	if [ -z $(which kubectl) ]; then
		# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
		sudo apt-get update
		sudo apt-get install -y apt-transport-https ca-certificates curl
		sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
		echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
		sudo apt-get update
		sudo apt-get install -y kubectl
	fi
}
