Set-Alias g git
Set-Alias rand Get-Random
Set-Alias c choco
Set-Alias irt iisreset
Set-Alias which Get-Command
Set-Alias dc docker-compose
# Set-Alias curl Invoke-WebRequest
Set-Alias ll "ls -la"

. $microsoftPowershellProfilePrivateAliasScriptDir\profile.grep.ps1
. $microsoftPowershellProfilePrivateAliasScriptDir\profile.powershell.ps1
. $microsoftPowershellProfilePrivateAliasScriptDir\profile.service.ps1
. $microsoftPowershellProfilePrivateAliasScriptDir\profile.sudo.ps1

function start-malias {vim $profile; vim "$microsoftPowershellProfilePrivateAliasScriptDir/profile.ps1"; vim "$microsoftPowershellProfilePrivateAliasScriptDir/profile.private.ps1"}
Set-Alias malias "start-malias"
function start-guid {[System.Guid]::NewGuid()}
Set-Alias guid "start-guid"
function start-mssql([String]$args) {mssql-cli $args}
Set-Alias mssql "start-mssql"
function start-mssqllocal {mssql-cli -S localhost -E}
Set-Alias mssqllocal "start-mssqllocal"
function start-catssh {Get-Content ~/.ssh/id_rsa.pub}
Set-Alias catssh "start-catssh"
function start-cdssh {Set-Location ~/.ssh}
Set-Alias cdssh "start-cdssh"
function start-sasscomp {sass ./:./}
Set-Alias sasscomp "start-sasscomp"
function start-cdchoco { Set-Location "C:\ProgramData\chocolatey\bin" }
Set-Alias cdchoco "start-cdchoco"
function start-cdacrylic { Set-Location "C:\Program Files (x86)\Acrylic DNS Proxy" }
Set-Alias cdacrylic "start-cdacrylic"
function start-pdns { powershell -Command "cd 'C:\Program Files (x86)\Acrylic DNS Proxy'; & 'C:\Program Files (x86)\Acrylic DNS Proxy\PurgeAcrylicCacheData.bat';"; ipconfig /flushdns; }
Set-Alias pdns "start-pdns"
function start-edit { code . }
Set-Alias edit "start-edit"

#http://jongurgul.com/blog/get-stringhash-get-filehash/ 
Function Get-StringHash([String] $String,$HashName = "SHA256") 
{ 
    $StringBuilder = New-Object System.Text.StringBuilder 
    [System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
        [Void]$StringBuilder.Append($_.ToString("x2")) 
     } 
     $StringBuilder.ToString() 
}

function start-cdl($target)
{
    if($target.EndsWith(".lnk"))
    {
        $sh = new-object -com wscript.shell
        $fullpath = resolve-path $target
        $targetpath = $sh.CreateShortcut($fullpath).TargetPath
        set-location $targetpath
    }
    else {
        set-location $target
    }
}
Set-Alias cdl "start-cdl"

. $microsoftPowershellProfilePrivateAliasScriptDir\profile.git.ps1
. $microsoftPowershellProfilePrivateAliasScriptDir\setowner.ps1
