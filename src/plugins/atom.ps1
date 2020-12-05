if ($Online) {
  $AtomRelease = DownloadString "https://api.github.com/repos/atom/atom/releases/latest" | ConvertFrom-Json |
  Select-Object -Expand assets | Where-Object { $_.Name -match "atom-x64-windows.zip" }
  $AtomDownloadUrl = $AtomRelease.browser_download_url -split " " | Select-Object -First 1
}

InstallTool -Name "Atom" -Url $AtomDownloadUrl -Prefix atom* | Out-Null
Add-Launch -Name "Atom" -Target "$(FindTool atom*)\atom.exe"
