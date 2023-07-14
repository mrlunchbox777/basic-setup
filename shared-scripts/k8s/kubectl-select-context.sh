#! /usr/bin/env bash

# Thanks to Matthew Anderson for the powershell function that this was adapted from
contexts=$(kubectl config get-contexts -o name)
target_context="$1"
if [ -z "$target_context" ]; then
  current_context=$(kubectl config current-context)
  context_count=$(echo "$contexts" | wc -l)
  echo "Select Kubernetes Context"
  for i in {1..$context_count}; do
    echo $i $(echo "$contexts" | sed -n "$i"p)
  done
  echo "Which context to use (current - $current_context)?: " && read
  if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$context_count" ] && [ "$REPLY" -gt "0" ]; then
    target_context=$(echo $contexts | sed -n "$REPLY"p)
  else
    echo "Entry invalid, exiting..." >&2
    return 1
  fi
else
  target_context_exists=$(kcgc -o name | grep $target_context)
  if [ -z "$target_context_exists" ]; then
    echo "Context name invalid, exiting..." >&2
    return 1
  fi
fi
kubectl config use-context $target_context
