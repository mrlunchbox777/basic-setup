# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  $checkForRunVariableName="ShouldInstall_$($1 -replace '-','_')"
  $checkForRunVariableName="ShouldInstall_$($checkForRunVariableName -replace '.',':')"
  if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
    Write-Output "choco install $package -y"

    refreshenv
  }
}

function Install-ManyChocoPackageBasicSetup() {
  $packages=""
  foreach ($package in $args) {
    $checkForRunVariableName="ShouldInstall_$($1 -replace '-','_')"
    if ($true -eq [System.Environment]::GetEnvironmentVariable("$checkForRunVariableName")) {
      $packages+="$package "
    }
  }
  Write-Output "choco install $packages -y"

  refreshenv
}
