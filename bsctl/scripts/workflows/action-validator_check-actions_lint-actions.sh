#! /usr/bin/env bash

find .github/workflows -type f \( -iname \*.yaml -o -iname \*.yml \) \
    | grep -v codeql.yaml \
    | xargs -I {} action-validator --verbose {}
