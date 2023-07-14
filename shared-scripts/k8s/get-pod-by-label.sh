#! /usr/bin/env bash

local label_name="$2"
[ -z "$label_name" ] && local label_name="app"
local pod_id=$(kubectl get pods -l "$label_name"="$1" -o custom-columns=":metadata.name" | grep .)
echo "$pod_id"
