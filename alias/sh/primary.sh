alias guid='uuid'
alias ll="ls -la"

rgui() {
  killall plasmashell && kstart5 plasmashell
}

cddev() {
  cd ~/src
}

ffind() {
  sudo find / -type f -iname "$@"
}

dfind() {
  sudo find / -type d -iname "$@"
}

random() {
  local tempminvar=$1
  if [ -z "$tempminvar" ]; then
    local tempminvar=0
  fi
  local tempmaxvar=$2
  if [ -z "$tempmaxvar" ]; then
    local tempmaxvar=10
  fi
  local tempmaxvar=$(($tempmaxvar-$tempminvar+1))
  local randomvalvar=$((RANDOM))
  echo $(($tempminvar + ($randomvalvar % $tempmaxvar)))
}

remove-containers() {
  docker stop $(docker ps -aq)
  docker rm $(docker ps -aq)
}

full-docker-clear() {
  removecontainers
  docker network prune -f
  docker rmi -f $(docker images --filter dangling=true -qa)
  docker volume rm $(docker volume ls --filter dangling=true -q)
  docker rmi -f $(docker images -qa)
}

trim-end-of-string() {
  local sed_string="s/.\{$2\}$//"
  local trimmed_string=$(sed "$sed_string" <<<"$1")
  echo "$trimmed_string"
}

trim-whitespace() {
  local trimmed_string=$(echo "$1" | xargs)
  echo "$trimmed_string"
}

find-files-ignore() {
  local ignore_string=""
  for find_files_ignore_f in "$@"; do
    local ignore_string+=" -name \"$find_files_ignore_f\" -prune -o "
  done

  local ignore_string=$(trim-end-of-string "$ignore_string" 3)

  local run_trim_end_of_string="find ./ \\($ignore_string\\) -o -type f -print"
  eval $run_trim_end_of_string
}

count-lines-ignore() {
  find-files-ignore "$@" | xargs wc -l
}

grepx() {
  local current_command=$2
  if [ -z "$current_command" ]; then
    local current_command="code"
  fi
  grep -r "$1" | sed 's/:.*//' | sort -u | xargs -I % sh -c "$current_command \"%\""
}

how() {
  local command_to_search=$1
  local context_before_to_grab=$2
  local bat_lanuage_to_use=$3
  local context_after_to_grab=$4
  if [ -z "$bat_lanuage_to_use" ]; then
    local bat_lanuage_to_use="sh"
  fi
  if [ -z "$context_before_to_grab" ]; then
    local context_before_to_grab="3"
  fi
  if [ -z "$context_after_to_grab" ]; then
    local context_after_to_grab=$(echo "$context_before_to_grab" + 2 | bc)
  fi
  local type_output=$(type -a "$command_to_search")
  local error_output=$(echo "$type_output" | grep '^\w* not found$')
  if [ ! -z "$error_output" ]; then
    echo "$error_output" >&2
    return 1
  fi
  local alias_output=$(echo "$type_output" | grep '^\w* is an alias for .*$')
  local how_after=""
  if [ ! -z "$alias_output" ]; then
    local how_output="$type_output"
    local how_after="$(echo "$type_output" | sed 's/^\w* is an alias for\s//g' | awk '{print $1}')"
  else
    local how_output=$(echo "$type_output" | awk -F " " '{print $NF}' | \
      xargs -I % sh -c "echo \"--\" && grep -B \"$context_before_to_grab\" \
      -A \"$context_after_to_grab\" \"$command_to_search\" \"%\" && echo \"--\\nPulled from - %\\n\"")
  fi
  if [ -z "$(which bat)" ]; then
    echo "$how_output"
  else
    echo "$how_output" | bat -l "$bat_lanuage_to_use"
  fi
  if [ ! -z "$how_after" ]; then
    echo ""
    echo "--"
    echo "- running 'how $how_after'"
    echo "--"
    echo ""
    how "$how_after" "$2" "$3" "$4" "$5"
  fi
}

read-script() {
  cat "$1" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
}

diff-date() {
  local date1=$(date +%s -d $1)
  local date2=$(date +%s -d $2)
  local DIFF=$(( $date1-$date2 ))
  echo $DIFF
}

is-on-wsl() {
  if [ -d "/mnt/c/Windows" ]; then
    echo "true"
  else
    echo "false"
  fi
}

copy-kube-to-windows() {
  local is_on_wsl=$(is-on-wsl)
  if [[ "$is_on_wsl" == "true" ]]; then
    local windows_username="$1"
    if [ -z "$windows_username" ]; then
      local windows_username="$(whoami)"
    fi
    local target_dir="/mnt/c/Users/$windows_username"
    local source_dir="~"
    if [[ "$2" == "true" ]]; then
      local temp_dir="$target_dir"
      local target_dir="$source_dir"
      local source_dir="$temp_dir"
    fi
    if [ -d "$target_dir" ]; then
      if [ -d "$target_dir/.kube.bak/" ]; then
        echo "\"$target_dir/.kube.bak\" exists, would you like to remove it? [y/n]: " && read
        echo
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
          rm -rf "$target_dir/.kube.bak"
        else
          echo "Didn't remove \"$target_dir/.kube.bak\", exiting..." >&2
          return 1
        fi
      fi
      if [ -d "$target_dir/.kube" ]; then
        mv "$target_dir/.kube" "$target_dir/.kube.bak"
      fi
      cp -r "$HOME/.kube/" "$target_dir/"
    else
      echo "\"$target_dir\" doesn't seem to exist" >&2
      return 1
    fi
  else
    echo "This system doesn't seem to be on WSL" >&2
    return 1
  fi
}
