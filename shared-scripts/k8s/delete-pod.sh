#! /usr/bin/env bash

pod_id=$(k8s-get-pod-by-label "$1" "$2")
kubectl delete pod "$pod_id"
