# adapted from https://betterprogramming.pub/useful-kubectl-aliases-that-will-speed-up-your-coding-54960185d10
export BASIC_SETUP_ALPINE_IMAGE_TO_USE="docker.io/alpine:3"
export BASIC_SETUP_BASH_IMAGE_TO_USE="docker.io/bash:5"

complete -o default -F __start_kubectl k
