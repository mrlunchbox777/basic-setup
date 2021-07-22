# run install k9s function
run-install-k9s-basic-setup () {
  if [ -z $(which k9s) ]; then
    # https://github.com/derailed/k9s
    local target_dir="${dir}/../../k9s"
    if [ ! -f "$target_dir" ]; then
      git clone "git@github.com:derailed/k9s.git" "$target_dir"
      local before_k9s_build_dir="$(pwd)"
      cd "$target_dir"
      make build
      cd "$before_k9s_build_dir"
    fi
    ln -s "${target_dir}/execs/k9s" "/usr/bin/k9s"
  fi
}
