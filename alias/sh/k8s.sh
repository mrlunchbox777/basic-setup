# adapted from https://betterprogramming.pub/useful-kubectl-aliases-that-will-speed-up-your-coding-54960185d10
# TODO:these exports should be moved to defaults with options instead of environment variables
export BASIC_SETUP_ALPINE_IMAGE_TO_USE="docker.io/alpine:3"
export BASIC_SETUP_BASH_IMAGE_TO_USE="docker.io/bash:5"

complete -o default -F __start_kubectl k

# # kubectl get
# alias kg="k get"
# alias kga="kg --all-namespaces all"
# alias kgc="kg cronjobs"
# alias kgds="kg daemonsets"
# alias kgd="kg deployment"
# alias kgj="kg job"
# alias kgn="kg node"
# alias kgns="kg namespace"
# alias kgp="kg pod"
# alias kgr="kg replicasets"
# alias kgs="kg service"

# # kubectl describe
# alias kd="k describe"
# alias kdc="kd cronjobs"
# alias kdds="kd daemonsets"
# alias kdd="kd deployment"
# alias kdj="kd job"
# alias kdn="kd node"
# alias kdns="kd namespace"
# alias kdp="kd pod"
# alias kdr="kd replicasets"
# alias kds="kd service"

# # kubectl config
# alias kc="k config"
# alias kcc="kc current-context"
# alias kcgc="kc get-contexts"
# alias kcsc="kc set-context"
# alias kcuc="kc use-context"
# alias kcv="kc view"

# kubectl misc
alias ka='k apply'
alias krm='k delete'
alias kl='k logs'
alias ke='k exec'
alias kr='k run'
alias kmk='k create'

# scripts
alias kgpbl='k8s-get-pod-by-label'
alias krmp='k8s-delete-pod'
alias kgpl='k8s-get-pod-logs'
alias kgpi='k8s-get-pod-image'
alias kgdi='k8s-get-deploy-image'
alias kfp='k8s-forward-pod'
alias kgps='k8s-get-pod-shell'
alias kcps='k8s-create-pod-shell'
alias kcns='k8s-create-node-shell'
alias kgpp='k8s-get-pod-ports'
alias kglbn='k8s-get-labels-by-name'
alias ksc='k8s-kubectl-select-context'
alias ksn='k8s-kubectl-select-namespace'
alias krad='k8s-kubectl-restart-all-deployments'
alias krads='k8s-kubectl-restart-all-daemonsets'
