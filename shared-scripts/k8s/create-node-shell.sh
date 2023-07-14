#! /usr/bin/env bash

# TODO support other namespaces
# Adapted from https://stackoverflow.com/questions/67976705/how-does-lens-kubernetes-ide-get-direct-shell-access-to-kubernetes-nodes-witho
shared_scripts_dir=$(general-get-shared-scripts-dir)
node_name="$1"
nodes=$(kubectl get nodes -o=json | jq -r '.items | .[].metadata.name')
if [ -z "$node_name" ]; then
  node_count=$(echo "$nodes" | wc -l)
  echo "Select Kubernetes Node"
  for i in $(seq 1 $node_count); do
    echo $i $(echo "$nodes" | sed -n "$i"p)
  done
  echo "Which node to use?: " && read
  if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$node_count" ] && [ "$REPLY" -gt "0" ]; then
    node_name=$(echo $nodes | sed -n "$REPLY"p)
  else
    echo "Entry invalid, exiting..." >&2
    return 1
  fi
fi
node_exists=$(echo "$nodes" | grep "$node_name")
[ -z "$node_exists" ] && echo "No node with the name provided ($node_name), check below for nodes\n\n--\n$nodes\n--\n\nexiting..." && return 1
echo "Node found, creating pod to get shell"
pod_name=$(echo "node-shell-$(uuid)")
pod_yaml="/tmp/$pod_name.yaml"
# TODO make this make sense for windows nodes
# TODO default the image with optional parameters
sed \
  -e "s|\$BASIC_SETUP_ALPINE_IMAGE_TO_USE|$BASIC_SETUP_ALPINE_IMAGE_TO_USE|g" \
  -e "s|\$pod_name|$pod_name|g" \
  -e "s|\$node_name|$node_name|g" \
  "$shared_scripts_dir/../resources/k8s-yaml/node-shell.yaml" > "$pod_yaml"
failed="false"
exception=""
{
  kubectl apply -f "$pod_yaml"
  echo "Pod scheduled, waiting for running"
  node_shell_ready="false"
  while [[ "$node_shell_ready" == "false" ]]; do
    pod_exists=$(kubectl get pod $pod_name -n kube-system --no-headers --ignore-not-found)
    if [ -z "$pod_exists" ]; then
      sleep 1
    else
      current_phase=$(kubectl get pod $pod_name -n kube-system -o=jsonpath="{$.status.phase}")
      if [[ "$current_phase" == "Running" ]]; then
        node_shell_ready="true"
      else
        sleep 1
      fi
    fi
  done
  command_to_run="$2"
  if [ -z "$command_to_run" ]; then
    # TODO make this make sense for windows nodes
    command_to_run="[ -z \"$(which bash)\" ] && sh || bash"
  fi
  # TODO make this make sense for windows nodes
  kubectl exec $pod_name -n kube-system -it -- sh -c "$command_to_run"
} || {
  exception="$?"
  failed="true"
}

pod_exists=$(kubectl get pods $pod_name -n kube-system --no-headers --ignore-not-found)
if [[ ! -z "$pod_exists" ]]; then
  echo "Cleaning up node-shell pod"
  kubectl delete pod $pod_name -n kube-system
fi

rm "$pod_yaml"

if [[ "$failed" == "true" ]]; then
  echo "Failure detected, check logs, exiting...">&2
  echo "exception code - $exception">&2
  return $exception
fi
