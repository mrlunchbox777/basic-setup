function start-gcob([String]$branchname, [String]$remote = "origin") {git checkout -b $branchname; git push -u $remote $branchname;}
Set-Alias gcob "start-gcob"
function start-gbdr([String]$branchname, [String]$remote = "origin") {git push $remote --delete $branchname;}
Set-Alias gbdr "start-gbdr"
function start-gsmua { git submodule update --recursive --remote }
Set-Alias gsmua "start-gsmua"

Import-Module posh-git
