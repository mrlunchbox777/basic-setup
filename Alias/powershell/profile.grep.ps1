function start-grep([String]$pattern, [bool]$recurse = $false, [String]$path = "*.*") {if ($recurse) {Get-ChildItem -Recurse "$path" | Select-Object -Property Name | Select-String -Pattern "$pattern"}else{Get-ChildItem "$path" | Select-Object -Property Name | Select-String -Pattern "$pattern"}}
Set-Alias grep "start-grep"
function start-grepr([String]$pattern, [String]$path = "*.*") {Get-ChildItem -Recurse "$path" | grep -Pattern "$pattern"}
Set-Alias grepr "start-grepr"
function start-grepp([String]$pattern, [String]$path = "*.*") {Get-ChildItem -Recurse "$path" | grep -Pattern "$pattern" | Select-Object -Unique Path}
Set-Alias grepr "start-grepp"
