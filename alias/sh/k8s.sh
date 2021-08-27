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
alias kd='k delete'
alias kl='k logs'
alias ke='k exec'

function get-pod-by-name() {
  local label_name="$2"
  [ -z "$label_name" ] && local label_name="app"
  local pod_id=$(kubectl get pods -l "$label_name"="$1" -o custom-columns=":metadata.name" | grep .)
  echo "$pod_id"
}

function exec-pod() {
  local pod_id=$(get-pod-by-name "$1" "$2")
  kubectl exec "$pod_id" -it -- sh
}

function delete-pod() {
  local pod_id=$(get-pod-by-name "$1" "$2")
  kubectl delete pod "$pod_id"
}

function get-pod-logs() {
  local pod_id=$(get-pod-by-name "$1" "$2")
  kubectl logs -f "$pod_id"
}

function get-deploy-image() {
  local image=$(kubectl get deployment "$1" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
  echo "$image"
}

function forward-pod() {
  local pod_id=$(get-pod-by-name "$1" "$2")
  local pod_port="$3"
  [ -z "$pod_port" ] && local pod_port="80"
  local external_port="$4"
  kubectl port-forward "$pod_id" $external_port:$pod_port
}

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
  if [[ "$REPLY" =~ ^[0-9]$ ]] && [ "$REPLY" -le "$context_count" ] && [ "$REPLY" -gt "0" ]; then
    local target_context=$(echo $contexts | sed -n "$REPLY"p)
    kcuc $target_context
  else
    echo "Entry invalid, exiting.." >&2
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
  if [[ "$REPLY" =~ ^[0-9]$ ]] && [ "$REPLY" -le "$context_count" ] && [ "$REPLY" -gt "0" ]; then
    local target_context=$(echo $contexts | sed -n "$REPLY"p)
    kcsc --current --namespace="$current_namespace"
  else
    echo "Entry invalid, exiting.." >&2
    return 1
  fi
}
alias ksn=kubectl-select-namespace
