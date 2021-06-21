# Install-ChocoBasicSetup
function Get-EnvOrDefault($variableName, $defaultValue="") {
  $currentValue=[System.Environment]::GetEnvironmentVariable($variableName)
  $retVal=[System.String]::IsNullOrWhiteSpace($currentValue) ? "$defaultValue": "$currentValue"
  return $retVal
}
