# run-get-source-and-dir function
run-get-source-and-dir() {
  # Adapted from https://stackoverflow.com/questions/7665/how-to-resolve-symbolic-links-in-a-shell-script
  local run_get_source_and_dir_help_string=""
  run_get_source_and_dir_help_string+="error - no source passed in\\n"
  run_get_source_and_dir_help_string+="pass in source using the following\\n"
  run_get_source_and_dir_help_string+="\\n"
  run_get_source_and_dir_help_string+="* sh - source=\"\$0\"\\n"
  run_get_source_and_dir_help_string+="* bash - source=\"\${BASH_SOURCE[0]}\"\\n"
  run_get_source_and_dir_help_string+="* zsh - source=\"\${(%):-%x}\"\\n"
  run_get_source_and_dir_help_string+="\\n"
  run_get_source_and_dir_help_string+="output - rgsd=(\"source\", \"dir\")\\n"
  run_get_source_and_dir_help_string+="to use run -\\n"
  run_get_source_and_dir_help_string+="  run-get-source-and-dir \"\$source\"\\n"
  run_get_source_and_dir_help_string+="    source=\"\$rgsd[0]\"\\n"
  run_get_source_and_dir_help_string+="    dir=\"\$rgsd[1]\"\\n"
  run_get_source_and_dir_help_string+="  it seems that in some cases you'd need to access index 1 & 2 instead of 0 & 1\\n"
  run_get_source_and_dir_help_string+="\\n"
  run_get_source_and_dir_help_string+="after the eval statement\\n"
  run_get_source_and_dir_help_string+="* \$source will be set to source resolving symlinks\\n"
  run_get_source_and_dir_help_string+="* \$dir will be set to the parent dir of \$source\\n"

  local source="$1"
  local dir=""

  if [ -z "$source" ]; then
    echo -e "$run_get_source_and_dir_help_string" >&2
    [[ $- == *i* ]] && exit 1
  fi

  while [ -h "$source" ]; do # resolve $source until the file is no longer a symlink
    dir="$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )"
    source="$(readlink "$source")"
    [[ $source != /* ]] && \
      source="$dir/$source" # if $source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  dir="$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )"
  rgsd=("$source" "$dir")
}
