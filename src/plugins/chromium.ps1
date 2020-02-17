if ($Online) {
  $ChromiumRelease = (DownloadString "https://api.github.com/repos/Hibbiki/chromium-win64/releases" | ConvertFrom-Json) |
  Sort-Object tag_name -Descending | Select-Object -First 1
  $ChromiumVersion = $ChromiumRelease.tag_name
  $ChromiumDownloadFile = "chromium-$ChromiumVersion.7z"
  $ChromiumDownloadUrl = $ChromiumRelease | Select-Object -Expand assets |
  Where-Object { $_.Name -eq "chrome.sync.7z" } |
  ForEach-Object { $_.browser_download_url }
}
InstallTool -Name "Chromium" -Url $ChromiumDownloadUrl -Prefix chromium* -ToolFile $ChromiumDownloadFile
$ChromiumInstallFolder = FindTool chromium*
$ChromiumOriginalExecutable = "$ChromiumInstallFolder\chrome.exe"
$ChromiumExecutable = "$ChromiumInstallFolder\chromium.exe"

if ((Test-Path $ChromiumOriginalExecutable) -and !(Test-Path $ChromiumExecutable)) {
  Move-Item -Force $ChromiumOriginalExecutable $ChromiumExecutable
}

Add-Launch -Name "Chromium" -Target "$ChromiumExecutable"
