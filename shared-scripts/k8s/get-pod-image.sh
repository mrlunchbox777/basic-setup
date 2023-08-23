#! /usr/bin/env bash

pod_id=$(k8s-get-pod-by-label "$1" "$2")
# TODO - return an array instead
image=$(kubectl get pod "$pod_id" -o=jsonpath='{$.spec.containers[:1].image}')
echo "$image"
