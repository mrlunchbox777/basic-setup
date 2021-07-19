# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  $checkForRunVariableName="ShouldInstall_$($1 -replace '-','_')"
  $checkForRunVariableName="ShouldInstall_$($checkForRunVariableName -replace '.',':')"
  if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
    Write-Output "choco install $package -y"

    refreshenv
  }
}

function Install-ManyChocoPackageBasicSetup($packagesArray) {
  $packages=""
  foreach ($package in $packagesArray) {
    Write-Output "current package - $package"
    $checkForRunVariableName="ShouldInstall_$($1 -replace '-','_')"
    if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
      $packages+="$package "
    }
  }
  Write-Output "choco install $packages -y"

  refreshenv
}
