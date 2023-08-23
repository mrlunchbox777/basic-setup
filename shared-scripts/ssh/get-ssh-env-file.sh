#! /usr/bin/env bash

ssh_env="$HOME/.ssh/agent-environment"
final_ssh_env="${BASIC_SETUP_SSH_ENV:-$ssh_env}"
echo "$final_ssh_env"
