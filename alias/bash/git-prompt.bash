# Add posh git for bash
source $BASIC_SETUP_GENERAL_RC_DIR/../submodules/posh-git-sh/git-prompt.sh
PROMPT_COMMAND='__posh_git_ps1 "\u@\h:\w " "\\\$ ";'$PROMPT_COMMAND
