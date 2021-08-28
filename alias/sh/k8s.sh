# adapted from https://betterprogramming.pub/useful-kubectl-aliases-that-will-speed-up-your-coding-54960185d10
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

function get-pod-by-label() {
  local label_name="$2"
  [ -z "$label_name" ] && local label_name="app"
  local pod_id=$(kubectl get pods -l "$label_name"="$1" -o custom-columns=":metadata.name" | grep .)
  echo "$pod_id"
}
alias kgpbl='get-pod-by-label'

function delete-pod() {
  local pod_id=$(get-pod-by-label "$1" "$2")
  kubectl delete pod "$pod_id"
}

function get-pod-logs() {
  local pod_id=$(get-pod-by-label "$1" "$2")
  kubectl logs -f "$pod_id"
}
alias kgpl='get-pod-by-label'

function get-deploy-image() {
  local image=$(kubectl get deployment "$1" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
  echo "$image"
}
alias kgdi='get-deploy-image'

function forward-pod() {
  local pod_id=$(get-pod-by-label "$1" "$2")
  local pod_port="$3"
  [ -z "$pod_port" ] && local pod_port="80"
  local external_port="$4"
  kubectl port-forward "$pod_id" $external_port:$pod_port
}
alias kfp='forward-pod'

function get-pod-shell() {
  local pod_id=$(get-pod-by-label "$1" "$2")
  kubectl exec "$pod_id" -it -- sh
}
alias kgps='get-pod-shell'

function get-node-shell() {
  # Adapted from https://stackoverflow.com/questions/67976705/how-does-lens-kubernetes-ide-get-direct-shell-access-to-kubernetes-nodes-witho
  local node_name="$1"
  [ -z "$node_name" ] && echo "No node name provided, exiting..." && return 1
  local nodes=$(kubectl get nodes -o=json | jq '.items | .[].metadata.name' | sed 's/"//g')
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
    image: docker.io/alpine:3.9
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
    ke $pod_name -n kube-system -it -- sh
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
  local current_context=$(kubectl config current-context)
  local context_count=$(echo "$contexts" | wc -l)
  echo "Select Kubernetes Context"
  for i in {1..$context_count}; do
    echo $i $(echo "$contexts" | sed -n "$i"p)
  done
  echo "Which context to use (current - $current_context)?: " && read
  if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$context_count" ] && [ "$REPLY" -gt "0" ]; then
    local target_context=$(echo $contexts | sed -n "$REPLY"p)
    kcuc $target_context
  else
    echo "Entry invalid, exiting..." >&2
    return 1
  fi
}
alias ksc=kubectl-select-context

# Thanks to Matthew Anderson for the powershell function that this was adapted from
function kubectl-select-namespace {
  local namespaces=$(kubectl get namespaces -o json | jq '.items | .[].metadata.name' | sed 's/\"//g')
  local current_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}'; echo)
  local namespace_count=$(echo "$namespaces" | wc -l)
  echo "Select Kubernetes Namespace"
  for i in {1..$namespace_count}; do
    echo $i $(echo "$namespaces" | sed -n "$i"p)
  done
  echo "Which namespace to use (current - $current_namespace)?: " && read
  if [[ "$REPLY" =~ ^[0-9]*$ ]] && [ "$REPLY" -le "$namespace_count" ] && [ "$REPLY" -gt "0" ]; then
    local target_namespace=$(echo $namespaces | sed -n "$REPLY"p)
    kcsc --current --namespace="$target_namespace"
  else
    echo "Entry invalid, exiting..." >&2
    return 1
  fi
}
alias ksn=kubectl-select-namespace
