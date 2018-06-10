param(
  [object]$Config
)

AddToPath $PaltryBinFolder
if ($Config) {
  $Config.PSObject.Properties | ForEach-Object {
    $BinScriptPath = "$PaltryBinFolder\$($_.Name).cmd"
    $_.Value | Out-String | Out-FileForce $BinScriptPath
  }
}
