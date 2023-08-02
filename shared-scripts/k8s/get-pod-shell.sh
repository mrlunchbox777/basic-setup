#! /usr/bin/env bash

target_pod=$(k8s-get-pod-by-label "$1" "$2")
command_to_run="(( \$(command -v bash >/dev/null 2>&1; echo \$?) == 0 )) && bash || sh"
kubectl exec "$target_pod" -it -- sh -c "$command_to_run"
