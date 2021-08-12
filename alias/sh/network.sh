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
  echo "$device" | xargs -I % sh -c "ip addr show | awk \"/%/ {print}\""
}

my-local-ip() {
  local device=$(my-default-network-device)
  echo "$device" | xargs -I % sh -c "ip addr show | awk \"/%/ {print}\" | tr \" \" \"\\\n\" | awk '/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|(([a-f0-9:]+:+)+[a-f0-9]+)/ {print;exit}'"
}
