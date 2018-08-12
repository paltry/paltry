$OpenSslDownloadSite = "https://bintray.com/vszakats/generic"
if ($Online) {
  $OpenSslFile = Get-WebRequest "$OpenSslDownloadSite/openssl/_latestVersion#files" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.innerText } |
  Where-Object { $_ -match "^openssl-.*-win64-mingw.zip$" } |
  Sort-Object Value -Descending | Select-Object -First 1
  $OpenSslFolder = [io.path]::GetFileNameWithoutExtension($OpenSslFile)
  $OpenSslUrl = "$OpenSslDownloadSite/download_file?file_path=$OpenSslFile"
  $OpenSslDownloadFile = "$DownloadsFolder\$OpenSslFile"
  if (!(Test-Path "$ToolsFolder\$OpenSslFolder")) {
    $WebClient = Get-WebClient
    if (!(Test-Path $OpenSslDownloadFile)) {
      Confirm-Online
      Out-Info "Downloading OpenSSL..."
      $WebClient.DownloadFile($OpenSslUrl,$OpenSslDownloadFile)
    }
    Out-Info "Extracting OpenSSL..."
    7z x "$OpenSslDownloadFile" -o"$ToolsFolder"
  }
}

$OpenSslInstalledFolder = FindTool openssl*
FindBinAndAddToPath $OpenSslInstalledFolder
AddEnvExtension "OPENSSL_CONF" "$OpenSslInstalledFolder\openssl.cnf"
