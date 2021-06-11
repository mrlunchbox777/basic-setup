# set this to your $profile -
# . "$env:USERPROFILE\.ssh\Alias\profile.ps1"
$microsoftPowershellProfilePrivateAliasScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$microsoftPowershellProfilePrivateAliasScriptDir = "$microsoftPowershellProfilePrivateAliasScriptDir/powershell"


. $microsoftPowershellProfilePrivateAliasScriptDir\profile.primary.ps1
