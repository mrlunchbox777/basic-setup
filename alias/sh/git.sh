alias g='git'

git-submodule-update-all() {
  git submodule update --recursive --remote
}
alias gsmua='git-submodule-update-all'
