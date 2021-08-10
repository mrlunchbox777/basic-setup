# run install k9s function
run-install-k9s-basic-setup () {
  local should_install_k9s="false"
  if [ -z $(which k9s) ]; then
    local should_install_k9s="true"
  else
    if [[ "$BASICSETUPSHOULDFORCEUPDATEK9S" == "true" ]]; then
      local should_install_k9s="true"
    fi
  fi
  if [[ "$should_install_k9s" == "true" ]]; then
    # https://github.com/derailed/k9s
    local target_dir="${dir}/../../k9s"
    local before_k9s_build_dir="$(pwd)"
    if [ ! -d "$target_dir" ]; then
      git clone "git@github.com:derailed/k9s.git" "$target_dir"
      cd "$target_dir"
      make build
      cd "$before_k9s_build_dir"
      sudo ln -s "${target_dir}/execs/k9s" "/usr/bin/k9s"
    else
      cd "$target_dir"
      stash_name="$(uuid)"
      orig_branch_name="$(git rev-parse --abbrev-ref HEAD)"
      git stash push -m "$stash_name"
      git checkout master
      git pull
      make build
      cd "$before_k9s_build_dir"
      git checkout "$orig_branch_name"
      git stash list | grep "$stash_name" && git stash pop
    fi
  fi
}
