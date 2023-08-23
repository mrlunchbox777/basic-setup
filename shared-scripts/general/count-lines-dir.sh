#! /usr/bin/env bash

find "$@" -type f | sed "s/^/'/;s/$/'/" | xargs cat | wc -l
