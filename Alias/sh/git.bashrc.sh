gsmua()
{
  git submodule update --recursive --remote
}

source ~/.ssh/posh-git-sh/git-prompt.sh
PROMPT_COMMAND='__posh_git_ps1 "\u@\h:\w " "\\\$ ";'$PROMPT_COMMAND
