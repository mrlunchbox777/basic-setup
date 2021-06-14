alias guid='uuid'

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