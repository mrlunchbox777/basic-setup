#! /usr/bin/env bash

label_name="$2"
[ -z "$label_name" ] && label_name="app"
pod_id=$(kubectl get pods -l "$label_name"="$1" -o custom-columns=":metadata.name" | grep .)
echo "$pod_id"
