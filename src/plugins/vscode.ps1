param(
  [object]$Config
)

$VsCodeUrl = "https://vscode-update.azurewebsites.net/latest/win32-x64-archive/stable"
$VsCodeDataFolder = "$CurrentFolder\vscode"

InstallTool -Name "VS Code" -Url $VsCodeUrl -Prefix VSCode*
Add-Launch -Name "VS Code" -Target "$(FindTool VSCode*)\Code.exe" -Arguments "--user-data-dir ""$VsCodeDataFolder"" --extensions-dir ""$VsCodeDataFolder\extensions"""

if ($Config.settings) {
  Out-Info "Saving custom VS Code settings..."
  $VsCodeSettingsFile = "$VsCodeDataFolder\User\settings.json"
  $ExistingVsCodeSettings = Get-Content -ErrorAction Ignore $VsCodeSettingsFile | Out-String | ConvertFrom-Json
  $VsCodeSettings = New-Object PsObject
  $ExistingVsCodeSettings.PSObject.Properties | ForEach-Object {
    $VsCodeSettings | Add-Member -Force -MemberType $_.MemberType -Name $_.Name -Value $_.Value
  }
  $Config.settings.PSObject.Properties | ForEach-Object {
    $VsCodeSettings | Add-Member -Force -MemberType $_.MemberType -Name $_.Name -Value $_.Value
  }
  $VsCodeSettings | Out-Json $VsCodeSettingsFile
}
