#! /usr/bin/env bash

# NOTE: don't run environment-validation here, it could cause a loop

# TODO: make this more fully fledged

(($(command -v "$@" >/dev/null 2>&1; echo $?) == 0)) && echo true || echo false
