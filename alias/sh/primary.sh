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

my-public-ip() {
  dig +short myip.opendns.com @resolver1.opendns.com
}

my-default-network-device() {
  ip route show default | awk '/default/ {print}' | tr " " "\n" | awk '/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|(([a-f0-9:]+:+)+[a-f0-9]+)/ {getline;getline;print}'
}

my-mac() {
  my-default-network-device | xargs -I{} cat /sys/class/net/{}/address | sed -E ':a;N;$!ba;s/\r{0,1}\n/,/g'
}

my-default-route() {
  local device=$(my-default-network-device)
  ip addr show | awk "/$device/ {print}"
}

my-local-ip() {
  local device=$(my-default-network-device)
  ip addr show | awk "/$device/ {print}" | tr " " "\n" | awk '/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|(([a-f0-9:]+:+)+[a-f0-9]+)/ {print;exit}'
}
