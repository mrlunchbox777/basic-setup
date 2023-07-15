alias grepr='grep -r'
alias guid='uuid'
alias ll="ls -la"
alias tf="terraform"

alias cddev='general-cddev'
alias count-lines-dir='general-count-lines-dir'
alias dfind='general-dfind'
alias diff-date='general-diff-date'
alias ffind='general-ffind'
alias get-shared-scripts-dir="general-get-shared-scripts-dir"
alias get-source-and-dir="general-get-source-and-dir"
alias get-sandd="get-source-and-dir"
alias grepx='general-grepx'
alias random='general-random'
alias read-script='general-read-script'
alias iso-date='general-iso-date'

function general-identify-shell-function-wrapper() {
  shared_scripts_dir=$(get-shared-scripts-dir)
  . "$shared_scripts_dir/bin/general-identify-shell-function"
  identify-shell-function
}
alias identify-shell='general-identify-shell-function-wrapper'
