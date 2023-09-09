# Kubernetes Commands

## Command Info

*[basic command line tutorial](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview)*

*[developer roadmap](https://github.com/kamranahmedse/developer-roadmap)*

* tldr - get simple info on command
* man - get detailed info on command
* how - get source for command
* For basic info run `cs b` or `cs i`

## K8s Aliases

These are broken into levels by character. Each level represents a single character in most cases.

Example - kubectl = k, get = g, pod = p -- kgp == kubectl get pods

* First level
    * `alias k=kubectl`
* Second level
    * `g=get`
    * `d=describe`
* Third level
    * (get only) `a= --all-namespaces all`
    * `c=cronjobs`
    * `ds=daemonsets`
    * `d=deployment`
    * `j=job`
    * `n=node`
    * `ns=namespace`
    * `p=pod`
    * `r=replicasets`
    * `s=service`

Other Aliases

* `alias kc=kubectl config`
    * `c=current-context`
    * `gc=get-contexts`
    * `sc=set-context`
    * `uc=use-context`
    * `v=view`
* `alias ka=kubectl apply`
* `alias krm=kubectl delete`
* `alias kl=kubectl logs`
* `alias ke=kubectl exec`
* `alias kr=kubectl run`
* `alias kmk=kubectl create`

### K8s Scripts

run with `-h` to get more info

* `alias kgpbl='k8s-get-pod-by-label'`
* `alias krmp='k8s-delete-pod'`
* `alias kgpl='k8s-get-pod-logs'`
* `alias kgpi='k8s-get-pod-image'`
* `alias kgdi='k8s-get-deploy-image'`
* `alias kfp='k8s-forward-pod'`
* `alias kgps='k8s-get-pod-shell'`
* `alias kcps='k8s-create-pod-shell'`
* `alias kcns='k8s-create-node-shell'`
* `alias kgpp='k8s-get-pod-ports'`
* `alias kglbn='k8s-get-labels-by-name'`
* `alias ksc='k8s-kubectl-select-context'`
* `alias ksn='k8s-kubectl-select-namespace'`
* `alias krad='k8s-kubectl-restart-all-deployments'`
* `alias krads='k8s-kubectl-restart-all-daemonsets'`
