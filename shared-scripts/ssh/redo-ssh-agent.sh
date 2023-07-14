#! /usr/bin/env bash

# Adapted from https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
ssh_env="$(ssh-get-ssh-env-file)"
# Source SSH settings, if applicable
if [ -f "${ssh_env}" ]; then
  . "${ssh_env}" > /dev/null
  #ps ${SSH_AGENT_PID} doesn't work under cygwin
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    ssh-start-ssh-agent;
  }
else
  ssh-start-ssh-agent;
fi
