if ($Online) {
  $LazygitReleaseApiUrl = "https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
  $LazygitRelease = (DownloadString $LazygitReleaseApiUrl | ConvertFrom-Json) |
  Select-Object -Expand assets | Where-Object { $_.Name -match "lazygit.+Windows_x86_64.+" }
  $LazygitUrl = $LazygitRelease.browser_download_url -split " " | Select-Object -First 1
}
InstallTool -Name "Lazygit" -Url $LazygitUrl -Prefix lazygit*
