#! /usr/bin/env bash

bash <(kubectl get deploy -A -o json | jq -c -r '.items | .[] | "kubectl rollout restart deploy -n \(.metadata.namespace|@sh) \(.metadata.name|@sh)"')
