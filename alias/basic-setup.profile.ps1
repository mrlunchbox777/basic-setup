# set this to your $profile -
# . "$env:USERPROFILE\.ssh\Alias\profile.ps1"
$microsoftPowershellProfilePrivateAliasScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$microsoftPowershellProfilePrivateAliasScriptDir = "$microsoftPowershellProfilePrivateAliasScriptDir/powershell"
$env:microsoftPowershellProfilePrivateAliasScriptDir = "$microsoftPowershellProfilePrivateAliasScriptDir"

. $microsoftPowershellProfilePrivateAliasScriptDir/profile.primary.ps1
