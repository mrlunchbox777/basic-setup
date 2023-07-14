#! /usr/bin/env bash

pod_id=$(k8s-get-pod-by-label "$2" "$3")
pod_port="$1"
[ -z "$pod_port" ] && pod_port="80"
external_port="$4"
forward_pod_command="kubectl port-forward \"$pod_id\" $external_port:$pod_port"
failed="false"
temp_file_name=""
{
  temp_file_name="/tmp/basic-setup-forward-pod-$(uuid).log"
  sh -c "$forward_pod_command" &> $temp_file_name &
  port_forward_job=$(jobs | grep "sh -c \"\$forward_pod_command\" &> \$temp_file_name" | awk '{print $1}' | sed 's/\[*\]*//g')
  sleep 1
  forwarding_output=$(cat $temp_file_name)
  bound_port=$(echo "$forwarding_output" | awk '{print $3}' | sed -n 1p | awk -F: '{print $2}')
  echo "$forwarding_output"
  # TODO support open for mac here - https://superuser.com/questions/911735/how-do-i-use-xdg-open-from-xdg-utils-on-mac-osx
  xdg-open http://localhost:$bound_port </dev/null >/dev/null 2>&1 & disown
  echo "Bringing portforward back to foreground"
  fg %$port_forward_job
} || {
  failed="true"
}

if [[ "$failed" == "true" ]]; then
  echo "Failure detected, check logs ($temp_file_name), exiting..."
  return 1
fi
