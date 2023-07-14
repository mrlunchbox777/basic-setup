#! /usr/bin/env bash

k8s-get-pod-by-label "$1" "$2"
local pod_id="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
kubectl logs -f "$pod_id"
