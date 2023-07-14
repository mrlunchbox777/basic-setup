#! /usr/bin/env bash

target_pod=$(k8s-get-pod-by-label "$1" "$2")
kubectl exec "$target_pod" -it -- sh -c "[ -z \"$(which bash)\" ] && sh || bash"
