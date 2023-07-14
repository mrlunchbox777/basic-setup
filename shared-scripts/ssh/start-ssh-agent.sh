#! /usr/bin/env bash

# Adapted from https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
ssh_env="$(ssh-get-ssh-env-file)"
echo "Initialising new SSH agent..."
ssh-agent | sed 's/^echo/#echo/' > "${ssh_env}"
echo "succeeded"
chmod 600 "${ssh_env}"
. "${ssh_env}" > /dev/null
ssh-add
