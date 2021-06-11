function start-nps {Start-Process powershell; exit;}
Set-Alias nps "start-nps"

function start-newps {Start-Process powershell;}
Set-Alias newps "start-newps"

function start-rh {Get-History -Count 1 | Invoke-History}
Set-Alias rh "start-rh"

function start-mrh([String]$commandPrefix) {Get-History | Where-Object {$_.CommandLine.StartsWith($commandPrefix)} | Select-Object -last 1 | Invoke-History}
Set-Alias mrh "start-mrh"

function start-flf([String]$count = 10, [decimal]$unitSize = 1000000.0, $unitString = "MB") {Get-ChildItem -r | Sort-Object -descending -property length | Select-Object -first $count name, @{name="length";expression={($_.Length/$unitSize).ToString() + " $unitString"}}}
Set-Alias flf "start-flf"

function start-npss { Start-Process -FilePath cmd.exe -Verb Runas -ArgumentList '/k C:\PSTools\PsExec.exe -i -s powershell.exe'; }
Set-Alias npss "start-npss"

function start-ll {Get-ChildItem | Sort-Object LastWriteTime}
Set-Alias ll "start-ll"

function start-psversion { $PSVersionTable.PSVersion }
Set-Alias psversion "start-psversion"
