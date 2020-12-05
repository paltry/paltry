if ($Online) {
  $WizTreeDownloadPrefix = "https://wiztreefree.com"
  $WizTreeDownloadPath = Get-WebRequest "$WizTreeDownloadPrefix/download" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.href -replace "about:","" } |
  ForEach-Object { ([regex]'.*wiztree_[\d_]+_portable.zip$').Matches($_) |
    ForEach-Object { $_.Value } } | Select-Object -First 1
  $WizTreeDownloadUrl = "$WizTreeDownloadPrefix/$WizTreeDownloadPath"
}
InstallTool -Name "WizTree" -Url $WizTreeDownloadUrl -Prefix wiztree* | Out-Null
Add-Launch -Name "WizTree" -Target "$(FindTool wiztree*)\WizTree64.exe"
