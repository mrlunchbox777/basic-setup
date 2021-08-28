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
* `alias ksc=kubectl-select-context` see below
* `alias ksn=kubectl-select-namespace` see below

### K8s Functions

* `get-pod-by-name()`
  * arg1 - name of pod
  * arg2 - label name (defaults to `"app"`)
* `delete-pod()`
  * arg1 - name of pod
  * arg2 - label name (defaults to `"app"`)
* `get-pod-logs()`
  * arg1 - name of pod
  * arg2 - label name (defaults to `"app"`)
* `get-deploy-image()`
  * arg1 - name of deployment
* `get-pod-shell()`
  * arg1 - name of pod
  * arg2 - label name (defaults to `"app"`)
* `forward-pod()`
  * arg1 - name of pod
  * arg2 - label name (defaults to `"app"`)
  * arg3 - pod port (defaults to `80`)
  * arg4 - external port (defaults to k8s decides)
* `kubectl-select-context()`
  * Interactive select context using kubectl
* `kubectl-select-namespace()`
  * Interactive select namespace using kubectl
