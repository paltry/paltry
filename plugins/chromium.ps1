if($Online) {
  $ChromiumRelease = (DownloadString "https://api.github.com/repos/henrypp/chromium/releases" | ConvertFrom-Json) |
    ?{ $_.body -Like "*stable*" -And $_.tag_name -Like "*-win64" } |
    Sort-Object tag_name -Descending | Select-Object -First 1
  $ChromiumVersion = $ChromiumRelease.tag_name
  $ChromiumDownloadFile = "chromium-$ChromiumVersion.zip"
  $ChromiumDownloadUrl = $ChromiumRelease | Select-Object -Expand assets |
    ?{ $_.name -eq "chromium-nosync.zip" } | 
    %{ $_.browser_download_url }
}
InstallTool -Name "Chromium" -Url $ChromiumDownloadUrl -Prefix chromium* -ToolFile $ChromiumDownloadFile
Add-Launch -Name "Chromium" -Target "$(FindTool chromium*)\chrome.exe"