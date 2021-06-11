Set-Alias g git

. $microsoftPowershellProfilePrivateAliasScriptDir\profile.powershell.ps1
. $microsoftPowershellProfilePrivateAliasScriptDir\profile.service.ps1

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

. $microsoftPowershellProfilePrivateAliasScriptDir\setowner.ps1
