#! /usr/bin/env bash

# TODO: make this more fully fledged

(("$(command -v "$@" >/dev/null 2>&1; echo $?)" == 0)) && echo true || echo false
