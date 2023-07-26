#! /usr/bin/env bash

# TODO: make this more fully fledged

(("$(command -v "$@" 2>&1 > /dev/null; echo $?)" == 0)) && echo true || echo false
