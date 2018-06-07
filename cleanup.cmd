@echo off
title Cleanup Paltry

set TMP_SCRIPT="%TMP%\%~n0.ps1"
for /f "delims=:" %%a in ('findstr -n "^___" %0') do set "Line=%%a"
(for /f "skip=%Line% tokens=* eol=_" %%a in ('type %0') do echo(%%a) > %TMP_SCRIPT%

powershell -ExecutionPolicy RemoteSigned -File %TMP_SCRIPT%
exit

___SCRIPT___
Set-PSDebug -Trace 0
$CurrentFolder = $PWD
$ToolsFolder = "$CurrentFolder\tools"
$ToolsInfo = Get-Content "$ToolsFolder\tools.json" | Out-String | ConvertFrom-Json
$InstalledTools = $ToolsInfo.installed

Import-Module $PWD\plugins\lib.psm1

Out-Info "Cleaning up unused tools..."
Get-ChildItem "$ToolsFolder" |
  ?{ $_.PSIsContainer -And !($InstalledTools -Contains $_.FullName) } | %{
    Out-Info "Deleting $($_.FullName)"
	cmd /c "rmdir /s /q $($_.FullName)"
}
