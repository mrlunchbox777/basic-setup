# Install-ChocoPackageBasicSetup
function Install-ChocoPackageBasicSetup($package) {
  choco install $package -y
}

function Install-ManyChocoPackageBasicSetup() {
  foreach ($package in $args) {
    Install-ChocoPackageBasicSetup "$package"
  }
}
