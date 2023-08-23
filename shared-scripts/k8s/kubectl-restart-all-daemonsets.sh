#! /usr/bin/env bash

bash <(kubectl get daemonset -A -o json | jq -c -r '.items | .[] | "kubectl rollout restart daemonset -n \(.metadata.namespace|@sh) \(.metadata.name|@sh)"')
