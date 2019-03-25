$OpenSslDownloadSite = "https://bintray.com/vszakats/generic"
if ($Online) {
  $RedirectRequest = [System.Net.WebRequest]::Create("$OpenSslDownloadSite/openssl/_latestVersion#files")
  $RedirectRequest.AllowAutoRedirect = $false
  $RedirectResponse = $RedirectRequest.GetResponse()
  $RedirectUrl = $RedirectResponse.GetResponseHeader("Location")
  $OpenSslVersion = $RedirectUrl.Split("/") | Select-Object -Last 1
  $OpenSslFile = "openssl-$OpenSslVersion-win64-mingw.zip"
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
