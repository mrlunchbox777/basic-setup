#! /usr/bin/env bash

k8s-get-pod-by-label "$1" "$2"
pod_id="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
kubectl delete pod "$pod_id"
