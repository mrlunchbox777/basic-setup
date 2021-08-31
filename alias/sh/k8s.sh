# adapted from https://betterprogramming.pub/useful-kubectl-aliases-that-will-speed-up-your-coding-54960185d10
export BASIC_SETUP_APLINE_IMAGE_TO_USE="docker.io/alpine:3.9"
export BASIC_SETUP_BASH_IMAGE_TO_USE="docker.io/bash:5"

alias k=kubectl

# kubectl get
alias kg="k get"
alias kga="kg --all-namespaces all"
alias kgc="kg cronjobs"
alias kgds="kg daemonsets"
alias kgd="kg deployment"
alias kgj="kg job"
alias kgn="kg node"
alias kgp="kg pod"
alias kgr="kg replicasets"
alias kgs="kg service"

# kubectl describe
alias kd="k describe"
alias kdc="kd cronjobs"
alias kdds="kd daemonsets"
alias kdd="kd deployment"
alias kdj="kd job"
alias kdn="kd node"
alias kdp="kd pod"
alias kdr="kd replicasets"
alias kds="kd service"

# kubectl config
alias kc="k config"
alias kcc="kc current-context"
alias kcgc="kc get-contexts"
alias kcsc="kc set-context"
alias kcuc="kc use-context"
alias kcv="kc view"

# kubectl misc
alias ka='k apply'
alias krm='k delete'
alias kl='k logs'
alias ke='k exec'
alias kr='k run'
alias kmk='k create'

function get-pod-by-label() {
  BASIC_SETUP_GET_POD_BY_LABEL_POD_ID=""
  local pods=$(kgp -o=jsonpath='{$}' | jq '.items | .[].metadata.name' | sed 's/"//g')
  local pod_label_value="$1"
  if [ -z "$pod_label_value" ]; then
    local pod_count=$(echo "$pods" | wc -l)
    echo "Select Kubernetes Pod"
    for i in {1..$pod_count}; do
      echo $i $(echo "$pods" | sed -n "$i"p)
    done
    echo "Which pod to use?: " && read
    if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$pod_count" ] && [ "$REPLY" -gt "0" ]; then
      local pod_id=$(echo $pods | sed -n "$REPLY"p)
    else
      echo "Entry invalid, exiting..." >&2
      return 1
    fi
  else
    local label_name="$2"
    [ -z "$label_name" ] && local label_name="app"
    local pod_id=$(kubectl get pods -l "$label_name"="$pod_label_value" -o custom-columns=":metadata.name" | grep .)
  fi
  local pod_exists=$(echo "$pods" | grep "$pod_id")
  [ -z "$pod_exists" ] && echo "No pod with the name provided, check below for pods\n\n--\n$pods\n--\n\nexiting..." && return 1
  BASIC_SETUP_GET_POD_BY_LABEL_POD_ID="$pod_id"
  echo "$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
}
alias kgpbl='get-pod-by-label'

function delete-pod() {
  get-pod-by-label "$1" "$2"
  local pod_id="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
  kubectl delete pod "$pod_id"
}
alias krmp='delete-pod'

function get-pod-logs() {
  get-pod-by-label "$1" "$2"
  local pod_id="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
  kubectl logs -f "$pod_id"
}
alias kgpl='get-pod-logs'

function get-pod-image() {
  get-pod-by-label "$1" "$2"
  local pod_id="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
  local image=$(kubectl get pod "$pod_id" -o=jsonpath='{$.spec.containers[:1].image}')
  echo "$image"
}
alias kgpi='get-pod-image'

function get-deploy-image() {
  local image=$(kubectl get deployment "$1" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
  echo "$image"
}
alias kgdi='get-deploy-image'

function forward-pod() {
  get-pod-by-label "$2" "$3"
  local pod_id="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
  local pod_port="$1"
  [ -z "$pod_port" ] && local pod_port="80"
  local external_port="$4"
  local forward_pod_command="kubectl port-forward \"$pod_id\" $external_port:$pod_port"
  local failed="false"
  {
    local temp_file_name="/tmp/basic-setup-forward-pod-$(uuid).log"
    sh -c "$forward_pod_command" &> $temp_file_name &
    local port_forward_job=$(jobs | grep "sh -c \"\$forward_pod_command\" &> \$temp_file_name" | awk '{print $1}' | sed 's/\[*\]*//g')
    sleep 1
    local forwarding_output=$(cat $temp_file_name)
    local bound_port=$(echo "$forwarding_output" | awk '{print $3}' | sed -n 1p | awk -F: '{print $2}')
    echo "$forwarding_output"
    xdg-open http://localhost:$bound_port </dev/null >/dev/null 2>&1 & disown
    echo "Bringing portforward back to foreground"
    fg %$port_forward_job
  } || {
    local failed="true"
  }

  if [[ "$failed" == "true" ]]; then
    echo "Failure detected, check logs, exiting..."
    return 1
  fi
}
alias kfp='forward-pod'

function get-pod-shell() {
  get-pod-by-label "$1" "$2"
  local target_pod="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
  kubectl exec "$target_pod" -it -- sh -c "[ -z \"$(which bash)\" ] && sh || bash"
}
alias kgps='get-pod-shell'

function create-pod-shell() {
  local pod_name=$(echo "pod-shell-$(uuid)")
  local pod_yaml="
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: $pod_name
  name: $pod_name
  namespace: \"kube-system\"
spec:
  containers:
  - args:
      - \"-f\"
      - \"/dev/null\"
    command:
      - \"tail\"
    image: $BASIC_SETUP_BASH_IMAGE_TO_USE
    name: $pod_name
    resources:
      limits:
        cpu: 500m
        memory: 128Mi
    securityContext:
      privileged: true
  restartPolicy: \"Never\"
  terminationGracePeriodSeconds: 0
  tolerations:
    - operator: \"Exists\"
  "
  local failed="false"
  {
    echo "$pod_yaml" | kubectl apply -f -
    echo "Pod scheduled, waiting for running"
    local pod_shell_ready="false"
    while [[ "$pod_shell_ready" == "false" ]]; do
      local pod_exists=$(kgp $pod_name -n kube-system --no-headers --ignore-not-found)
      if [ -z "$pod_exists" ]; then
        sleep 1
      else
        local current_phase=$(kgp $pod_name -n kube-system -o=jsonpath="{$.status.phase}")
        if [[ "$current_phase" == "Running" ]]; then
          pod_shell_ready="true"
        else
          sleep 1
        fi
      fi
    done
    ke $pod_name -n kube-system -it -- bash
  } || {
    local failed="true"
  }

  local pod_exists=$(kgp $pod_name -n kube-system --no-headers --ignore-not-found)
  if [[ ! -z "$pod_exists" ]]; then
    echo "Cleaning up pod-shell pod"
    krm pod $pod_name -n kube-system
  fi

  if [[ "$failed" == "true" ]]; then
    echo "Failure detected, check logs, exiting..."
    return 1
  fi
}
alias kcps='create-pod-shell'

function get-node-shell() {
  # Adapted from https://stackoverflow.com/questions/67976705/how-does-lens-kubernetes-ide-get-direct-shell-access-to-kubernetes-nodes-witho
  local node_name="$1"
  local nodes=$(kubectl get nodes -o=json | jq '.items | .[].metadata.name' | sed 's/"//g')
  if [ -z "$node_name" ]; then
    local node_count=$(echo "$nodes" | wc -l)
    echo "Select Kubernetes Node"
    for i in {1..$node_count}; do
      echo $i $(echo "$nodes" | sed -n "$i"p)
    done
    echo "Which node to use?: " && read
    if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$node_count" ] && [ "$REPLY" -gt "0" ]; then
      local node_name=$(echo $nodes | sed -n "$REPLY"p)
    else
      echo "Entry invalid, exiting..." >&2
      return 1
    fi
  fi
  local node_exists=$(echo "$nodes" | grep "$node_name")
  [ -z "$node_exists" ] && echo "No node with the name provided, check below for nodes\n\n--\n$nodes\n--\n\nexiting..." && return 1
  echo "Node found, creating pod to get shell"
  local pod_name=$(echo "node-shell-$(uuid)")
  local pod_yaml="
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: $pod_name
  name: $pod_name
  namespace: \"kube-system\"
spec:
  containers:
  - args:
      - \"-t\"
      - \"1\"
      - \"-m\"
      - \"-u\"
      - \"-i\"
      - \"-n\"
      - \"sleep\"
      - \"14000\"
    command:
      - \"nsenter\"
    image: $BASIC_SETUP_APLINE_IMAGE_TO_USE
    name: $pod_name
    resources:
      limits:
        cpu: 500m
        memory: 128Mi
    securityContext:
      privileged: true
  dnsPolicy: ClusterFirst
  hostPID: true
  hostIPC: true
  hostNetwork: true
  nodeSelector:
    \"kubernetes.io/hostname\": \"$node_name\"
  restartPolicy: \"Never\"
  terminationGracePeriodSeconds: 0
  tolerations:
    - operator: \"Exists\"
  "
  local failed="false"
  {
    echo "$pod_yaml" | kubectl apply -f -
    echo "Pod scheduled, waiting for running"
    local node_shell_ready="false"
    while [[ "$node_shell_ready" == "false" ]]; do
      local pod_exists=$(kgp $pod_name -n kube-system --no-headers --ignore-not-found)
      if [ -z "$pod_exists" ]; then
        sleep 1
      else
        local current_phase=$(kgp $pod_name -n kube-system -o=jsonpath="{$.status.phase}")
        if [[ "$current_phase" == "Running" ]]; then
          node_shell_ready="true"
        else
          sleep 1
        fi
      fi
    done
    local command_to_run="$2"
    if [ -z "$command_to_run" ]; then
      local command_to_run="[ -z \"$(which bash)\" ] && sh || bash"
    fi
    ke $pod_name -n kube-system -it -- sh -c "$command_to_run"
  } || {
    local failed="true"
  }

  local pod_exists=$(kgp $pod_name -n kube-system --no-headers --ignore-not-found)
  if [[ ! -z "$pod_exists" ]]; then
    echo "Cleaning up node-shell pod"
    krm pod $pod_name -n kube-system
  fi

  if [[ "$failed" == "true" ]]; then
    echo "Failure detected, check logs, exiting..."
    return 1
  fi
}
alias kgns='get-node-shell'

function get-pod-ports() {
  # get-pod-by-label "$1" "$2"
  local target_pod="$BASIC_SETUP_GET_POD_BY_LABEL_POD_ID"
  local found_target_pod="false"
  if [[ -z "$target_pod" ]]; then
    local pod_description=$(kgp $target_pod -o json)
    local pod_image=$(echo "$pod_description" | jq '.spec.containers | .[0].image' | sed 's/"//g')
    local pod_node=$(echo "$pod_description" | jq '.spec.nodeName' | sed 's/"//g')
    local docker_inspect_command_extra=""
    local docker_inspect_command="docker$docker_inspect_command_extra inspect --format='{{.Config.ExposedPorts}}' $pod_image"
    local full_inspect_command="echo '' && echo 'Ports:' && $docker_inspect_command && echo ''"
    local found_target_pod="true"
  fi
  {
    [[ "$found_target_pod" == "true" ]] && \
      kgns "$pod_node" "$full_inspect_command"
  } || {
    echo "Failed to 'docker inspect' on the node, trying locally..."
    [ -z "$pod_image" ] && [[ ! -z "$1" ]] && local pod_image="$1"
    local docker_inspect_command_extra=" image"
    local docker_inspect_command="docker$docker_inspect_command_extra inspect --format='{{.Config.ExposedPorts}}' $pod_image"
    local full_inspect_command="echo '' && echo 'Ports:' && $docker_inspect_command && echo ''"
    docker pull "$pod_image"
    sh -c "$full_inspect_command"
    echo "Ran local 'local docker inspect'"
  }
}
alias kgpp='get-pod-ports'

function get-labels-by-name() {
  local resource_kind="$2"
  [ -z "$resource_kind" ] && local resource_kind="pod"
  local pod_labels=$(kubectl get $resource_kind "$1" -o=jsonpath='{$.metadata.labels}')
  echo "$pod_labels" | jq
}
alias kglbn='get-labels-by-name'

# Thanks to Matthew Anderson for the powershell function that this was adapted from
function kubectl-select-context {
  local contexts=$(kubectl config get-contexts -o name)
  local target_context="$1"
  if [ -z "$target_context" ]; then
    local current_context=$(kubectl config current-context)
    local context_count=$(echo "$contexts" | wc -l)
    echo "Select Kubernetes Context"
    for i in {1..$context_count}; do
      echo $i $(echo "$contexts" | sed -n "$i"p)
    done
    echo "Which context to use (current - $current_context)?: " && read
    if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$context_count" ] && [ "$REPLY" -gt "0" ]; then
      local target_context=$(echo $contexts | sed -n "$REPLY"p)
    else
      echo "Entry invalid, exiting..." >&2
      return 1
    fi
  else
    local target_context_exists=$(kcgc -o name | grep $target_context)
    if [ -z "$target_context_exists" ]; then
      echo "Context name invalid, exiting..." >&2
      return 1
    fi
  fi
  kcuc $target_context
}
alias ksc=kubectl-select-context

# Thanks to Matthew Anderson for the powershell function that this was adapted from
function kubectl-select-namespace {
  local namespaces=$(kubectl get namespaces -o json | jq '.items | .[].metadata.name' | sed 's/\"//g')
  local target_namespace="$1"
  if [ -z "$target_namespace" ]; then
    local current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}'; echo)
    local namespace_count=$(echo "$namespaces" | wc -l)
    echo "Select Kubernetes Namespace"
    for i in {1..$namespace_count}; do
      echo $i $(echo "$namespaces" | sed -n "$i"p)
    done
    echo "Which namespace to use (current - $current_namespace)?: " && read
    if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$namespace_count" ] && [ "$REPLY" -gt "0" ]; then
      local target_namespace=$(echo $namespaces | sed -n "$REPLY"p)
    else
      echo "Entry invalid, exiting..." >&2
      return 1
    fi
  else
    local target_namespace_exists=$(kg ns $target_namespace --no-headers --ignore-not-found)
    if [ -z "$target_namespace_exists" ]; then
      echo "Namespace invalid, exiting..." >&2
      return 1
    fi
  fi
  kcsc --current --namespace="$target_namespace"
}
alias ksn=kubectl-select-namespace
