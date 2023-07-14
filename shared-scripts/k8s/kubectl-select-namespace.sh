#! /usr/bin/env bash

# Thanks to Matthew Anderson for the powershell function that this was adapted from
namespaces=$(kubectl get namespaces -o json | jq '.items | .[].metadata.name' | sed 's/\"//g')
target_namespace="$1"
if [ -z "$target_namespace" ]; then
  current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}'; echo)
  namespace_count=$(echo "$namespaces" | wc -l)
  echo "Select Kubernetes Namespace"
  for i in $(seq 1 $namespace_count); do
    echo "$i - $(echo "$namespaces" | sed -n "$i"p)"
  done
  read -p "Which namespace to use (current - $current_namespace)?: " REPLY
  echo "reply - $REPLY"
  if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$namespace_count" ] && [ "$REPLY" -gt "0" ]; then
    target_namespace=$(echo "$namespaces" | sed -n "$REPLY"p)
    # TODO: add verbosity when we add options
    # echo $namespaces
    # echo "selected $target_namespace"
  else
    echo "Entry invalid, exiting..." >&2
    return 1
  fi
else
  target_namespace_exists=$(kubectl get ns $target_namespace --no-headers --ignore-not-found)
  if [ -z "$target_namespace_exists" ]; then
    echo "Namespace invalid, exiting..." >&2
    return 1
  fi
fi
kubectl config set-context --current --namespace="$target_namespace"
