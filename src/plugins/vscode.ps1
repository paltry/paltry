$VsCodeUrl = "https://vscode-update.azurewebsites.net/latest/win32-x64-archive/stable"
$VsCodeDataFolder = "$CurrentFolder\vscode"

InstallTool -Name "VS Code" -Url $VsCodeUrl -Prefix VSCode*
Add-Launch -Name "VS Code" -Target "$(FindTool VSCode*)\Code.exe" -Arguments "--user-data-dir ""$VsCodeDataFolder"" --extensions-dir ""$VsCodeDataFolder\extensions"""
