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

### K8s Functions

* `get-pod-by-label()`
  * arg1 - value of label
  * arg2 - label name (defaults to `"app"`)
  * `alias kgpbl='get-pod-by-label'`
* `delete-pod()`
  * arg1 - value of label
  * arg2 - label name (defaults to `"app"`)
  * no alias
* `get-pod-logs()`
  * arg1 - value of label
  * arg2 - label name (defaults to `"app"`)
  * `alias kgpl='get-pod-logs'`
* `get-deploy-image()`
  * arg1 - name of deployment
  * `alias kgdi='get-deploy-image'`
* `forward-pod()`
  * arg1 - value of label
  * arg2 - label name (defaults to `"app"`)
  * arg3 - pod port (defaults to `80`)
  * arg4 - external port (defaults to k8s decides)
  * `alias kfp='forward-pod'`
* `get-pod-shell()`
  * arg1 - value of label (defaults to interactive)
  * arg2 - label name (defaults to `"app"`)
  * `alias kgps=get-pod-shell`
* `get-node-shell()`
  * arg1 - name of node (default interactive)
  * `alias kgns='get-node-shell'`
* `get-labels-by-name()`
  * arg1 - value of label
  * arg2 - resource kind (defaults to `pod`)
  * alias kglbn='get-labels-by-name'
* `kubectl-select-context()`
  * arg1 - name of context (default interactive)
  * `alias ksc=kubectl-select-context`
* `kubectl-select-namespace()`
  * arg1 - name of namespace (default interactive)
  * `alias ksn=kubectl-select-namespace`
