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
alias kcsc="kc set-context"
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
