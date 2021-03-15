$OpenSslDownloadSite = "https://indy.fulgan.com/SSL"
if ($Online) {
  $OpenSslFile = Get-WebRequest $OpenSslDownloadSite |
  ForEach-Object { $_.Links } | ForEach-Object { $_.href } |
  ForEach-Object { $_ -replace "about:","" } |
  Where-Object { $_ -match "openssl-.+-x64_86-win64\.zip$" } |
  Sort-Object -Descending | Select-Object -First 1
  $OpenSslDownloadUrl = "$OpenSslDownloadSite/$OpenSslFile"
}

InstallTool -Name "OpenSSL" -Url $OpenSslDownloadUrl -Prefix openssl* | Out-Null
