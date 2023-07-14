#! /usr/bin/env bash

target_pod=$(k8s-get-pod-by-label "$1" "$2")
found_target_pod="false"
if [[ ! -z "$target_pod" ]]; then
  pod_description=$(kubectl get pod $target_pod -o json)
  pod_image=$(echo "$pod_description" | jq '.spec.containers | .[0].image' | sed 's/"//g')
  pod_node=$(echo "$pod_description" | jq '.spec.nodeName' | sed 's/"//g')
  docker_inspect_command_extra=""
  docker_inspect_command="docker$docker_inspect_command_extra inspect --format='{{.Config.ExposedPorts}}' $pod_image"
  full_inspect_command="echo '' && echo 'Ports:' && $docker_inspect_command && echo ''"
  found_target_pod="true"
fi
{
  [[ "$found_target_pod" == "true" ]] && \
    k8s-create-node-shell "$pod_node" "$full_inspect_command"
} || {
  echo "Failed to 'docker inspect' on the node, trying locally..."
  [ -z "$pod_image" ] && [[ ! -z "$1" ]] && pod_image="$1"
  docker_inspect_command_extra=" image"
  docker_inspect_command="docker$docker_inspect_command_extra inspect --format='{{.Config.ExposedPorts}}' $pod_image"
  full_inspect_command="echo '' && echo 'Ports:' && $docker_inspect_command && echo ''"
  docker pull "$pod_image"
  sh -c "$full_inspect_command"
  echo "Ran local 'local docker inspect'"
}
