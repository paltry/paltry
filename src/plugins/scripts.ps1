param(
  [object]$Config
)

if ($Config) {
  Confirm-Folder $ScriptsFolder
  Remove-Item "$ScriptsFolder\*"
  AddToPath $ScriptsFolder
  $Config.PSObject.Properties | ForEach-Object {
    $BinScriptPath = "$ScriptsFolder\$($_.Name).cmd"
    $_.Value | Out-String | Out-FileForce $BinScriptPath
  }
}
