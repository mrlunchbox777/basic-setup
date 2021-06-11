Set-Alias gservice Get-Service
Set-Alias nservice New-Service

function start-removeservice([String]$name) {$newName = Get-Service $name | Select-Object -ExpandProperty Name;sc.exe delete $newName}
Set-Alias removeservice "start-removeservice"
function start-sservice([String]$name) {net start $name;}
Set-Alias sservice "start-sservice"
function start-tservice([String]$name) {net stop $name;}
Set-Alias tservice "start-tservice"
function start-rservice([String]$name) {net stop $name; net start $name;}
Set-Alias rservice "start-rservice"
