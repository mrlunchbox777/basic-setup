gcob()
{
    local branchname=$1
    local remote=""
    if [ -z "$2" ]
    then
        remote="origin"
    else
        remote="$2"
    fi
    git checkout -b $branchname
    git push -u $remote $branchname
}

gbdr()
{
    local branchname=$1
    local remote=""
    if [ -z "$2" ]
    then
        remote="origin"
    else
        remote="$2"
    fi
    git push $remote --delete $branchname;
}

gsmua()
{
    git submodule update --recursive --remote
}

source ~/.ssh/posh-git-sh/git-prompt.sh
PROMPT_COMMAND='__posh_git_ps1 "\u@\h:\w " "\\\$ ";'$PROMPT_COMMAND
