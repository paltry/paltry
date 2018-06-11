param(
  [object]$Config
)

AddEnvExtension "PALTRY_HOME" $CurrentFolder
AddEnvExtension "PALTRY_CWD" $ConfigCwd

if ($Config) {
  $Config.PSObject.Properties | ForEach-Object { AddEnvExtension $_.Name $_.Value }
}
