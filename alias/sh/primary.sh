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
  local context_before_to_grab=$2
  local context_after_to_grab=$3
  if [ -z "$context_before_to_grab" ]; then
    local context_before_to_grab="3"
  fi
  if [ -z "$context_after_to_grab" ]; then
    local context_after_to_grab=$(echo "$context_before_to_grab" + 2 | bc)
  fi
  type -a "$1" | awk -F " " '{print $NF}' | \
    xargs -I % sh -c "echo \"\n--\" && grep -B \"$context_before_to_grab\" \
    -A \"$context_after_to_grab\" \"$1\" \"%\" && echo \"--\\nPulled from - %\\n\""
}
