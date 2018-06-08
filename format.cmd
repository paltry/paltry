@echo off
title Format Paltry Code

set TMP_SCRIPT="%TMP%\%~n0.ps1"
for /f "delims=:" %%a in ('findstr -n "^___" %0') do set "Line=%%a"
(for /f "skip=%Line% tokens=* eol=_" %%a in ('type %0') do echo(%%a) > %TMP_SCRIPT%

powershell -ExecutionPolicy Bypass -File %TMP_SCRIPT%
exit

___SCRIPT___
Set-PSDebug -Trace 0
Install-Module -Name PowerShell-Beautifier
Import-Module PowerShell-Beautifier.psd1
Get-ChildItem -Path $PWD -Include *.ps1,*.psm1 -Recurse | Edit-DTWBeautifyScript