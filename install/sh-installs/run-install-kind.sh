# run install kind function
run-install-kind-basic-setup () {
  if [[ "$should_install_kind" == "true" ]]; then
    # https://kind.sigs.k8s.io/docs/user/quick-start/#installation
    if [ -z $(which kind) ]; then
      # adding this to path is in alias
      go get kind
    else
      echo "kind already installed"
    fi
  fi
}
