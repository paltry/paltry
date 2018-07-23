@echo off
title Build Paltry

for /r %%f in (*.ps*) do (echo.>%%~f:Zone.Identifier)
powershell -ExecutionPolicy Bypass -File .\src\build.ps1
pause
