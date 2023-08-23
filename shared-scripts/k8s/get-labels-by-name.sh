#! /usr/bin/env bash

resource_kind="$2"
[ -z "$resource_kind" ] && resource_kind="pod"
pod_labels=$(kubectl get $resource_kind "$1" -o=jsonpath='{$.metadata.labels}')
echo "$pod_labels" | jq
