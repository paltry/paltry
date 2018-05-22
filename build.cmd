@echo off
title Build Paltry Console

set TMP_SCRIPT="%TMP%\%~n0.ps1"
for /f "delims=:" %%a in ('findstr -n "^___" %0') do set "Line=%%a"
(for /f "skip=%Line% tokens=* eol=_" %%a in ('type %0') do echo(%%a) > %TMP_SCRIPT%

powershell -ExecutionPolicy RemoteSigned -File %TMP_SCRIPT%
exit

___SCRIPT___
Set-PSDebug -Trace 0
$CurrentFolder = $PWD
$UserProfile = $Env:USERPROFILE
$DownloadsFolder = "$UserProfile\Downloads"
$TempFolder = "$UserProfile\Temp"
$ToolsFolder = "$CurrentFolder\tools"
$PluginsFolder = "$CurrentFolder\plugins"
$LaunchFolder = "$CurrentFolder\launch"
$Config = Get-Content 'config.json' | Out-String | ConvertFrom-Json
$Online = Test-Connection -ComputerName 8.8.8.8 -Quiet -ErrorAction Ignore
$Global:PathExtensions = @()
Import-Module $PWD\plugins\lib.psm1

Out-Info "Setting Up..."
SetupFolders

Out-Info "Loading Plugins..."
Get-ChildItem "$PluginsFolder\*.ps1" | %{
  Out-Title "[$($_.BaseName)]"
  $Version = $Config.versions."$($_.BaseName)"
  & $_ -Version $Version -UseLatestVersion (!$Version)
}

Out-Console
explorer $LaunchFolder
