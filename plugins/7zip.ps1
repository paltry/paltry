$7ZipUrl = "http://www.7-zip.org/a/7z1604-x64.msi"
$7ZipFile = $7ZipUrl.Split("/") | Select-Object -Last 1
$7ZipFolder = [io.path]::GetFileNameWithoutExtension($7ZipFile)
$7ZipInstallerFile = "$DownloadsFolder\$7ZipFile"
$7ZipInstallerFolder = "$TempFolder\$7ZipFolder"
$7ZipInstalledFolder = "$ToolsFolder\$7ZipFolder"
if(!(Test-Path $7ZipInstalledFolder)) {
  if(!(Test-Path $7ZipInstallerFile)) {
    Confirm-Online
    Out-Info "Downloading 7-Zip..."
    DownloadFile $7ZipUrl $7ZipInstallerFile
  }
  Out-Info "Extracting 7-Zip..."
  msiexec /a "$7ZipInstallerFile" TARGETDIR="$7ZipInstallerFolder" /qn | Out-Null
  Move-Item "$7ZipInstallerFolder\Files\7-Zip" $7ZipInstalledFolder -Force
  Remove-Item -Recurse -Force -ErrorAction Ignore $7ZipInstallerFolder
}
AddToPath $7ZipInstalledFolder
Add-Launch -Name "7-Zip" -Target "$7ZipInstalledFolder\7zFM.exe"
