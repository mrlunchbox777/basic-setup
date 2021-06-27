# Update-ProfileBasicSetup
function Update-ProfileBasicSetup() {
  $profileSet = "$(Select-String ".*basic-setup\.profile\.ps1" "$profile")"
  if (($true -eq "$env:ShouldUpdateBasicSetupProfile") -and ($true -eq "$profileSet")) {
    $target_dir="$env:DIR/../alias/basic-setup.profile.ps1"
    Write-Output "" >> "$profile"
    Write-Output ". \"$target_dir\"" >> "$profile"
  } else {
    Write-Output "Skipping updating profile..."
  }
}
