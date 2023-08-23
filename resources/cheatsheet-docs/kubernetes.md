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

To use these put `k8s-` before the name and drop the .sh, this value is also shown in the alias

Note: Once these are migrated to using options, -h on all of them will give you the info rather than this doc

* `get-pod-by-label.sh`
    * arg1 - value of label (defaults to interactive)
    * arg2 - label name (defaults to `"app"`)
    * `alias kgpbl='k8s-get-pod-by-label'`
* `delete-pod.sh`
    * arg1 - value of label (defaults to interactive)
    * arg2 - label name (defaults to `"app"`)
    * `alias krmp='k8s-delete-pod'`
* `get-pod-logs.sh`
    * arg1 - value of label (defaults to interactive)
    * arg2 - label name (defaults to `"app"`)
    * `alias kgpl='k8s-get-pod-logs'`
* `get-pod-image.sh`
    * arg1 - value of label (defaults to interactive)
    * arg2 - label name (defaults to `"app"`)
    * `alias kgpi='k8s-get-pod-image'`
* `get-deploy-image.sh`
    * arg1 - name of deployment
    * `alias kgdi='k8s-get-deploy-image'`
* `forward-pod.sh`
    * arg1 - pod port (defaults to `80`)
    * arg2 - value of label (defaults to interactive)
    * arg3 - label name (defaults to `"app"`)
    * arg4 - external port (defaults to k8s decides)
    * `alias kfp='k8s-forward-pod'`
* `get-pod-shell.sh`
    * arg1 - value of label (defaults to interactive)
    * arg2 - label name (defaults to `"app"`)
    * `alias kgps=k8s-get-pod-shell`
* `create-pod-shell.sh`
    * `alias kcps='k8s-create-pod-shell'`
* `create-node-shell.sh`
    * arg1 - name of node (default interactive)
    * `alias kgns='k8s-create-node-shell'`
* `get-pod-ports.sh`
    * arg1 - value of label (defaults to interactive)
    * arg2 - label name (defaults to `"app"`)
    * `alias kgpp='k8s-get-pod-ports'`
* `get-labels-by-name.sh`
    * arg1 - value of label
    * arg2 - resource kind (defaults to `pod`)
    * `alias kglbn='k8s-get-labels-by-name'`
* `kubectl-select-context.sh`
    * arg1 - name of context (default interactive)
    * `alias ksc=k8s-kubectl-select-context`
* `kubectl-select-namespace()`
    * arg1 - name of namespace (default interactive)
    * `alias ksn=kubectl-select-namespace`
* `kubectl-reset-all-deployments.sh`
    * `alias krad=k8s-kubectl-reset-all-deployments`
* `kubectl-reset-all-deamonsets.sh`
    * `alias krads=k8s-kubectl-reset-all-deamonsets`
