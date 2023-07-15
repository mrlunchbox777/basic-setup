#! /usr/bin/env bash

# TODO: support more than apt (and linux)
sudo apt-get update -y
sudo apt-get -u upgrade --assume-no
sudo apt-get upgrade -y
sudo apt-get autoremove -y
