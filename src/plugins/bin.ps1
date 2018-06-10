param(
  [object]$Config
)

if ($Config) {
  Confirm-Folder $PaltryBinFolder
  Remove-Item "$PaltryBinFolder\*"
  AddToPath $PaltryBinFolder
  $Config.PSObject.Properties | ForEach-Object {
    $BinScriptPath = "$PaltryBinFolder\$($_.Name).cmd"
    $_.Value | Out-String | Out-FileForce $BinScriptPath
  }
}
