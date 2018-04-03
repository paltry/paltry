if($Online) {
  $SmartGitDownloadUrl = Invoke-WebRequest -Uri "https://www.syntevo.com/smartgit/download" |
    %{ $_.Links } | %{ $_.href } |
    %{ ([regex]'.*smartgit-portable-[\d_]+.7z$').Matches($_) | %{ $_.Value } } |
    %{ "https://www.syntevo.com$_" } | Select-Object -First 1
}
InstallTool -Name "SmartGit" -Url $SmartGitDownloadUrl -Prefix smartgit*
Add-Launch -Name "SmartGit" -Target "$(FindTool smartgit*)\bin\smartgit.exe"