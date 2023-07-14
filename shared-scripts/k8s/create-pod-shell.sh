#! /usr/bin/env bash

# TODO support other namespaces
pod_name=$(echo "pod-shell-$(uuid)")
pod_yaml="/tmp/$pod_name.yaml"
# TODO make this make sense for windows nodes
# TODO default the image with optional parameters
sed \
  -e "s|\$BASIC_SETUP_BASH_IMAGE_TO_USE|$BASIC_SETUP_BASH_IMAGE_TO_USE|g" \
  -e "s|\$pod_name|$pod_name|g" \
  "$BASICSETUPGENERALRCDIR/../resources/k8s-yaml/pod-shell.yaml" > "$pod_yaml"
failed="false"
{
  kubectl apply -f "$pod_yaml"
  echo "Pod scheduled, waiting for running"
  pod_shell_ready="false"
  while [[ "$pod_shell_ready" == "false" ]]; do
    pod_exists=$(kubectl get pod $pod_name -n kube-system --no-headers --ignore-not-found)
    if [ -z "$pod_exists" ]; then
      sleep 1
    else
      current_phase=$(kgp $pod_name -n kube-system -o=jsonpath="{$.status.phase}")
      if [[ "$current_phase" == "Running" ]]; then
        pod_shell_ready="true"
      else
        sleep 1
      fi
    fi
  done
  kubectl exec $pod_name -n kube-system -it -- bash
} || {
  failed="true"
}

pod_exists=$(kubectl get pod $pod_name -n kube-system --no-headers --ignore-not-found)
if [[ ! -z "$pod_exists" ]]; then
  echo "Cleaning up pod-shell pod"
  kubectl delete pod $pod_name -n kube-system
fi
rm "$pod_yaml"

if [[ "$failed" == "true" ]]; then
  echo "Failure detected, check logs, exiting..."
  return 1
fi
