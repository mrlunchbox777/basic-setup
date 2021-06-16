#send-message.sh
function Send-Message {
  Write-Output "********************************************************"
  Write-Output "*"
  Write-Output "* $(Get-Date)"
  foreach ($f in $args) {
    Write-Output "* $f"
  }
  Write-Output "*"
  Write-Output "********************************************************"
}