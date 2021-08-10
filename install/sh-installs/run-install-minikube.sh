# run install minikube function
run-install-minikube-basic-setup () {
  local should_install_minikube="false"
  if [ -z $(which minikube) ]; then
    local should_install_minikube="true"
  fi
  if [[ "$BASICSETUPSHOULDFORCEINSTALLMINIKUBE" == "true" ]]; then
    local should_install_minikube="true"
  fi
  if [[ "$should_install_minikube" == "true" ]]; then
    # https://v1-18.docs.kubernetes.io/docs/tasks/tools/install-minikube/
    if [ -z $(grep -E --color 'vmx|svm' /proc/cpuinfo) ]; then
      echo "System doesn't support virtualization" >&2
      return 1
    fi
    # https://linuxapt.com/blog/533-install-minikube-on-ubuntu-20-04
    sudo apt install virtualbox virtualbox-ext-pack
    wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    chmod +x minikube-linux-amd64
    sudo mv minikube-linux-amd64 /usr/local/bin/minikube
  fi
}
