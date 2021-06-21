# Install-PostGit
function Install-PostGit() {
  # pulled from - https://github.com/dahlbyk/posh-git

  # (A) You've never installed posh-git from the PowerShell Gallery
  PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

  # TODO, figure when to install posh git vs when not to
  # need to check this stuff - https://docs.microsoft.com/en-us/powershell/module/powershellget/get-installedmodule?view=powershell-7.1
}
