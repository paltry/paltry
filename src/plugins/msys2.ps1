if ($Online) {
  $MSYS2RepoUrl = "http://repo.msys2.org/distrib/x86_64"
  $MSYS2File = Get-WebRequest $MSYS2RepoUrl | ForEach-Object { $_.Links } | ForEach-Object { $_.href -replace "about:","" } | Where-Object { $_ -match "msys2-base-x86_64-.+\.tar\.xz" } |
  Sort-Object -Descending | Select-Object -First 1
  $MSYS2DownloadUrl = "$MSYS2RepoUrl/$MSYS2File"
}
InstallTool -Name "MSYS2" -Url $MSYS2DownloadUrl -Prefix msys2*
