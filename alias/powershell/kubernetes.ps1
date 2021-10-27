$env:BASIC_SETUP_APLINE_IMAGE_TO_USE="docker.io/alpine:3.9"
set-alias k kubectl

function get-node-shell($inputNodeName = "", $inputCommandToRun = "") {
  # Adapted from https://stackoverflow.com/questions/67976705/how-does-lens-kubernetes-ide-get-direct-shell-access-to-kubernetes-nodes-witho
  $node_name="$inputNodeName"
  $nodes=$(kubectl get nodes -o=json | ConvertFrom-Json).items | % -Process {echo $_.metadata.name}  
  if([System.String]::IsNullOrWhiteSpace("$node_name")) {
    $i=0
    foreach ($currentNode in $nodes) {
      $i++
      echo "$i - $currentNode"
    }
    $nodeToUse=Read-Host -Prompt "Which node to use?"
    if (("$nodeToUse" -match "^[0-9]*$") -and ("$nodeToUse" -lt $nodes.Length) -and ("$nodeToUse" -gt 0)) {
      $node_name=$nodes[$nodeToUse-1]
    } else {
      throw "Entry invalid, exiting..."
    }
  }
  $node_exists=$($nodes | Where-Object {"$_" -eq "$node_name"}) -gt 0
  if (! $node_exists) {
    throw "No node with the name provided ($node_name), check below for nodes`n`n--`n$nodes`n--`n`nexiting..."
  }
  echo "Node found, creating pod to get shell"
  $pod_name=$(echo "node-shell-$([GUID]::NewGuid().Guid)")
  $pod_yaml="/tmp/${pod_name}.yaml"
  # TODO make this make sense for windows nodes
  $(Get-Content "$env:microsoftPowershellProfilePrivateAliasScriptDir/../k8s-yaml/node-shell.yaml") `
    -replace "\`$BASIC_SETUP_APLINE_IMAGE_TO_USE",$env:BASIC_SETUP_APLINE_IMAGE_TO_USE`
    -replace "\`$pod_name","$pod_name"`
    -replace "\`$node_name","$node_name"`
    > "$pod_yaml"
  $failed="$false"
  try {
    kubectl apply -f "$pod_yaml"
    echo "Pod scheduled, waiting for running"
    $node_shell_ready="false"
    while("$node_shell_ready" -eq "$false") {
      $pod_exists=$(kubectl get pod $pod_name -n kube-system --no-headers --ignore-not-found)
      if([System.String]::IsNullOrWhiteSpace("$pod_exists")) {
        Start-Sleep 1
      } else {
        $current_phase=$(kubectl get pod $pod_name -n kube-system -o=jsonpath="{$.status.phase}")
        if("$current_phase" -eq "Running") {
          $node_shell_ready="true"
        } else {
          Start-Sleep 1
        }
      }
    }
    $command_to_run="$inputCommandToRun"
    if([System.String]::IsNullOrWhiteSpace($command_to_run)) {
      # TODO make this make sense for windows nodes
      $command_to_run='[ -z \"$(which bash)\" ] && sh || bash'
    }
    # TODO make this make sense for windows nodes
    kubectl exec $pod_name -n kube-system -it -- sh -c "$command_to_run"
  } catch {
    $failed="$true"
  }

  $pod_exists=$(kubectl get pod $pod_name -n kube-system --no-headers --ignore-not-found)
  if(! [System.String]::IsNullOrWhiteSpace("$pod_exists")) {
    echo "Cleaning up node-shell pod"
    kubectl delete pod $pod_name -n kube-system
  }
  rm "$pod_yaml"

  if ("$failed" -eq "$true") {
    throw "Failure detected, check logs, exiting..."
  }
}
set-alias kgns 'get-node-shell'
