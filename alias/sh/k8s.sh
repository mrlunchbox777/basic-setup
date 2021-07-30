# adapted from https://betterprogramming.pub/useful-kubectl-aliases-that-will-speed-up-your-coding-54960185d10
# TODO finish k8s aliases
alias k=kubectl

alias kg="k get"
alias kgc="kg cronjobs"
alias kgds="kg daemonsets"
alias kgd="kg deployment"
alias kgj="kg job"
alias kgn="kg node"
alias kgp="kg pod"
alias kgr="kg replicasets"
alias kgs="kg service"

alias kd="k describe"
alias kdc="kd cronjobs"
alias kdds="kd daemonsets"
alias kdd="kd deployment"
alias kdj="kd job"
alias kdn="kd node"
alias kdp="kd pod"
alias kdr="kd replicasets"
alias kds="kd service"

alias kc="k config"
alias kcc="kc current-context"
alias kcsc="kc set-context"
alias kcv="kc view"

function get-pod-by-name() {
  local label_name="$2"
  if [ -z "$label_name" ]; then
    label_name="app"
  fi
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
