# Cheatsheet Alias

## Cheatsheet

* `alias cs=cheatsheet`
  * Get more info using `cs i` or `cs`

## Env-var

Saved for future use

## Git

* `alias g='git'`
* `gsmua()` - check with `how()`

## GPG

* `export GPG_TTY=$(tty)`
  * This just sets the GPG interactive terminal to an interactive terminal (useful for vscode & wsl)

## Import-nvm

* Adds the nvm dir to the path, adds nvm to the shell, and adds nvm bash completion
  * Pulled from [here](https://github.com/nvm-sh/nvm#git-install)

## K8s

### K8s Aliases

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
    * `sc=set-context`
    * `v=view`
  * `alias ka=kubectl apply`
  * `alias kd=kubectl delete`
  * `alias kl=kubectl logs`
  * `alias ke=kubectl exec`

### K8s Functions

  * `get-pod-by-name()`
    * arg1 - name of pod
    * arg2 - label name (defaults to app)
  * `exec-pod()`
    * arg1 - name of pod
    * arg2 - label name (defaults to app)
  * `delete-pod()`
    * arg1 - name of pod
    * arg2 - label name (defaults to app)
  * `get-pod-logs()`
    * arg1 - name of pod
    * arg2 - label name (defaults to app)
  * `get-deploy-image()`
    * arg1 - name of deployment
  * `forward-pod()`
    * arg1 - name of pod
    * arg2 - label name (defaults to app)
    * arg3 - pod port (defaults to 80)
    * arg4 - external port (defaults to k8s decides)

## Network

* `my-public-ip()`
* `my-default-network-device()`
* `my-mac()`
* `my-default-route()`
* `my-local-ip()`

## Primary

* `alias guid='uuid'`
* `alias ll="ls -la"`
* `rgui()`
  * Restarts plasmashell (KDE)
* `cddev()` - check with `how()`
* `ffind()` - check with `how()`
* `dfind()` - check with `how()`
* `random()`
  * arg 1 - min value (defaults to 0)
  * arg 2 - max value (default to 10)
* `remove-containers()` - check with `how()`
* `full-docker-clear()` - check with `how()`
* `trim-end-of-string()` - check with `how()`
* `trim-whitespace()` - check with `how()`
* `find-files-ignore()` - check with `how()`
  * takes any number of args as ignore strings
* `count-lines-ignore()` - check with `how()`
  * takes any number of args as ignore strings
* `grepx()` - check with `how()`
  * grep | sed | xargs
  * arg 1 - regex for grep
  * arg 2 - command to run (defaults to code)
* `how()`
  * arg 1 - command to get source for
  * arg 2 - context before command (defaults to 3)
  * arg 3 - bat language to use (defaults to sh)
  * arg 4 - context after command (defaults to arg2 + 2)
* `read-script()`
  * arg 1 - location of `script` output to read
* `diff-date()`
  * arg 1 - `date` minuend
  * arg 2 - `date` subrahend
* `is_on_wsl()` - check with `how()`
