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
