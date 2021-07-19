# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  $checkForRunVariableName="ShouldInstall_$($package -replace '-','_')"
  $checkForRunVariableName="ShouldInstall_$($checkForRunVariableName -replace '.',':')"
  if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
    Write-Output "choco install $package -y"

    refreshenv
  }
}

function Install-ManyChocoPackageBasicSetup() {
  Param(
    [Parameter(Mandatory=$true,
    ValueFromPipeline=$true)]
    [String[]]
    $packagesArray
  )
  $packages=""
  foreach ($package in $packagesArray) {
    Write-Output "current package - $package"
    $checkForRunVariableName="ShouldInstall_$($package -replace '-','_')"
    if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
      Write-Output "adding package - $package"
      $packages+="$package "
    } else {
      $currentRunVal=[System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")
      Write-Output "skipping package - $package - $checkForRunVariableName - $currentRunVal"
    }
  }
  Write-Output "choco install $packages -y"

  refreshenv
}
