# Add posh git for bash
source $BASICSETUPGENERALRCDIR/../posh-git-sh/git-prompt.sh
PROMPT_COMMAND='__posh_git_ps1 "\u@\h:\w " "\\\$ ";'$PROMPT_COMMAND
