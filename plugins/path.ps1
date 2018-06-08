param(
  [object]$Config
)

$Config | ForEach-Object {
  AddToolToPath $_
}
