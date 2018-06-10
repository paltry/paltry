if ($Online) {
  $SmartGitDownloadUrl = Invoke-WebRequest -Uri "https://www.syntevo.com/smartgit/download" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.href } |
  ForEach-Object { ([regex]'.*smartgit-portable-[\d_]+.7z$').Matches($_) | ForEach-Object { $_.Value } } |
  ForEach-Object { "https://www.syntevo.com$_" } | Select-Object -First 1
}
InstallTool -Name "SmartGit" -Url $SmartGitDownloadUrl -Prefix smartgit*
Add-Launch -Name "SmartGit" -Target "$(FindTool smartgit*)\bin\smartgit.exe"
