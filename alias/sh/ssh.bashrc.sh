# ssh bashrc

SSH_ENV="$HOME/.ssh/agent-environment"

function start_ssh_agent {
  echo "Initialising new SSH agent..."
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo "succeeded"
  chmod 600 "${SSH_ENV}"
  . "${SSH_ENV}" > /dev/null
  /usr/bin/ssh-add
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}"]; then
  . "${SSH_ENV}" > /dev/null
  #ps ${SSH_AGENT_PID} doesn't work under cygwin
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_ssh_agent;
  }
else
  start_ssh_agent;
fi
