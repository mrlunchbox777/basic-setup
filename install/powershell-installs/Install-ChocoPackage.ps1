# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  $check_for_run_variable_name="should_install_$($1 -replace '-','_')"
  if ( $true -eq [System.Environment]::GetEnvironmentVariable("$check_for_run_variable_name") ) {
    Write-Output "choco install $package -y"
  }
}

function Install-ManyChocoPackageBasicSetup() {
  $packages=""
  foreach ($package in $args) {
    $check_for_run_variable_name="should_install_$($1 -replace '-','_')"
    if ( $true -eq [System.Environment]::GetEnvironmentVariable("$check_for_run_variable_name") ) {
      $packages+="$package"
    }
  }
  Write-Output "choco install $package -y"

  refresh-env
}
