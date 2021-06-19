# ssh generalrc
# Adapted from https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login

SSH_ENV="$HOME/.ssh/agent-environment"

function start_ssh_agent {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo "succeeded"
  chmod 600 "${SSH_ENV}"
  source "${SSH_ENV}" > /dev/null
  /usr/bin/ssh-add
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}"]; then
  source "${SSH_ENV}" > /dev/null
  #ps ${SSH_AGENT_PID} doesn't work under cygwin
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_ssh_agent;
  }
else
  start_ssh_agent;
fi

#######################################
# Possible update from https://github.com/pawnstar/
#######################################
# SSH_AUTH_SOCK=$HOME/.ssh/agent.socket
  
# # If there's an old socket file that isn't in use, remove it
# if [ -S $SSH_AUTH_SOCK ] && ! (ps x | grep ssh-agent | grep -v grep > /dev/null); then
#   rm $SSH_AUTH_SOCK
# fi
# # If there's some other file (non-socket) exit with failure
# if [ -e $SSH_AUTH_SOCK ] && [ ! -S $SSH_AUTH_SOCK ]; then
#   echo "Cannot start SSH Agent - socket file exists but is not a socket"
#   exit 1
# fi
# # If we don't have a socket file yet, start a new agent to make one
# if [ ! -S $SSH_AUTH_SOCK ]; then
#   ssh-agent -a $SSH_AUTH_SOCK > /dev/null;
# fi
# # Otherwise just set the env var so SSH client can connect to the socket
# export SSH_AUTH_SOCK;