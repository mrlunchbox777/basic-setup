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
    tempminvar=0
  fi
  local tempmaxvar=$2
  if [ -z "$tempmaxvar" ]; then
    tempmaxvar=10
  fi
  tempmaxvar=$(($tempmaxvar-$tempminvar+1))
  local randomvalvar=$((RANDOM))
  # echo "$tempminvar + ( $randomvalvar % $tempmaxvar )"
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

trim-string() {
  local sed_string="s/.\{$2\}$//"
  local trimmed_string=$(sed "$sed_string" <<<"$1")
  echo "$trimmed_string"
}

find-files-ignore() {
  local ignore_string=""
  for find_files_ignore_f in "$@"; do
    ignore_string+=" -name \"$find_files_ignore_f\" -prune -o "
  done

  ignore_string=$(trim-string "$ignore_string" 3)

  run_trim_string="find ./ \\($ignore_string\\) -o -type f -print"
  eval $run_trim_string
}

count-lines-ignore() {
  find-files-ignore "$@" | xargs wc -l
}

grep-sed-xargs() {
  local current_command=$2
  if [ -z "$current_command" ]; then
    local current_command="code"
  fi
  grep -r "$1" | sed 's/:.*//' | xargs -I % sh -c "$current_command \"%\""
}
