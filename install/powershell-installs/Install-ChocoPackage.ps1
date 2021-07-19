# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  $checkForRunVariableName="ShouldInstall_$($package -replace '-','_')"
  $checkForRunVariableName="ShouldInstall_$($checkForRunVariableName -replace '.',':')"
  if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
    choco install $package -y
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
    $checkForRunVariableName="ShouldInstall_$($package -replace '-','_')"
    if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
      $packages+="$package "
    }
  }

  choco install $packages -y
  refreshenv
}
