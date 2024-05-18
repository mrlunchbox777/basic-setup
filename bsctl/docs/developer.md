# bsctl

CLI tool to simplify development, deployment, auditing and troubleshooting of BigBang in a kubernetes cluster.

## Contributing

See [here](https://github.com/mrlunchbox777/basic-setup/blob/main/.github/CONTRIBUTING.md).

## Development Environment

This supports [devbox](https://www.dev-box.app/) and [devcontainers](https://containers.dev/), you can replicate those locally if you wish by reading the relevant files. If you use [vscode](https://code.visualstudio.com/), you can just install [the devcontainers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and vscode will prompt you to relaunch there and you will have all needed tooling.

### Build only with no local install

Execute the following from the project root to build the binary without local install
```bash
make build
# OR
go build
```

Run the built binary using dot-slash
```bash
make run version
# OR
./bsctl version
```

### Build and Install

Execute the following from the project root to build the executable and make it available in $GOPATH/bin directory:
```bash
make install
# OR
go install
```

Run the installed bsctl tool
```bash
bsctl version
```

### Run unit tests

```bash
make coverage
# OR
make test
# OR
go test -v ./... -coverprofile=cover.txt
```

### Run lint checks

Linting checks code quality based on best practice. For now the [linter tool](https://golangci-lint.run/welcome/install/) is no longer [the one from the golang project](https://github.com/golang/lint) as it's deprecated. To manually run the linter follow these steps.
1. install the tool
    ```bash
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    ```
2. Run the linter from this project's root directory
    ```bash
    make lint
    # OR
    golangci-lint run ./...
    ```
3. Set it up in vscode
    1. Open User Settings (visual)
    1. Search for golang
    1. Change the `Go: Lint Tool` to `golangci-lint`

## Development Tasks

Here some common development tasks will be laid out with common issues and solutions.

### Upgrading

```bash
go get -u

# You should immediately build and run tests afterwards
make all
# OR
go build
go test -v -coverprofile=test.out -cover ./...
```

#### Problem Packages

1. None so far

#### Debugging New Problem Packages

1. n/a
