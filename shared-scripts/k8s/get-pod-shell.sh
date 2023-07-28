#! /usr/bin/env bash

target_pod=$(k8s-get-pod-by-label "$1" "$2")
command_to_run="(( \$(command -v bash 2>&1 > /dev/null; echo \$?) != 0 )) && sh || bash"
kubectl exec "$target_pod" -it -- sh -c "$command_to_run"
