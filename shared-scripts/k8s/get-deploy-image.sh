#! /usr/bin/env bash

# TODO - return an array instead
image=$(kubectl get deployment "$1" -o=jsonpath='{$.spec.template.spec.containers[:1].image}')
echo "$image"
