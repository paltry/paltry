Set-PSDebug -Trace 0
$SourceFolder = "$Env:PALTRY_HOME\src"
$ToolsFolder = "$Env:PALTRY_HOME\tools"
$ToolsInfo = Get-Content -ErrorAction Ignore "$ToolsFolder\tools.json" | Out-String | ConvertFrom-Json
$InstalledTools = $ToolsInfo.installed

Import-Module $SourceFolder\lib.psm1

if (!$InstalledTools) {
  Exit-Error "No tools installed! Please run the build script first."
}

Out-Info "Cleaning up unused tools..."
Get-ChildItem "$ToolsFolder" |
Where-Object { $_.PSIsContainer -and !($InstalledTools -contains $_.FullName) } | ForEach-Object {
  Out-Info "Deleting $($_.FullName)"
  cmd /c "rmdir /s /q $($_.FullName)"
}
