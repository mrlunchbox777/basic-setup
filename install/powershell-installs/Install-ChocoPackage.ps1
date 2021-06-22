# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  Write-Output "choco install $package -y"
}

function Install-ManyChocoPackageBasicSetup() {
  $packages=""
  foreach ($package in $args) {
    $packages+="$package"
  }
  Install-ChocoPackageBasicSetup "$packages"
}
