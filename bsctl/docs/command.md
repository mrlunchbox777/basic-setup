# Command Semantics

bsctl draws upon the command syntax from the practices followed in kubectl.

## Syntax

Use the following syntax to run bsctl commands from your terminal window:

```bash
bsctl [COMMAND] [TYPE] [NAME] [FLAGS]
```

where COMMAND, TYPE, NAME, and FLAGS are:

* __COMMAND__: Specifies the operation that you want to perform on one or more resources, for example list, get. This applies in situations where we have a specific resource and the usage of REST style verb and resource is appropriate. However, in some cases, the command does not apply to a specific resource but the BigBang deployment as a whole, so using the operation name is enough, e.g., querying the status of current BigBang deployment:
    ```bash
        bsctl version
    ```
* __FLAGS__: Specifies optional flags. For example, you can use the --kubeconfig flag to explicitly specify the location of kube config file. Some flags are specific to a given specific bsctl commands while other flags like --namespace and --kubeconfig are available for all the bsctl commands:
    ```bash
        bsctl k8s createNodeShell //not yet implemented
    ```
