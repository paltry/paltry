if ($Online) {
  $WizTreeDownloadUrl = Get-WebRequest "https://antibody-software.com/web/software/software/wiztree-finds-the-files-and-folders-using-the-most-disk-space-on-your-hard-drive" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.href } |
  ForEach-Object { ([regex]'.*wiztree_[\d_]+_portable.zip$').Matches($_) |
    ForEach-Object { $_.Value } } | Select-Object -First 1
}
InstallTool -Name "WizTree" -Url $WizTreeDownloadUrl -Prefix wiztree*
Add-Launch -Name "WizTree" -Target "$(FindTool wiztree*)\WizTree64.exe"
