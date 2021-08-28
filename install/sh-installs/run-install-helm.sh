# run install helm function
run-install-helm-basic-setup () {
  if [ -z "$(which helm)" ]; then
    # pulled from https://helm.sh/docs/intro/install/
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm -y
  fi
}
