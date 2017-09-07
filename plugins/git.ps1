if($Online) {
  $GitReleaseApiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
  $MinGitRelease = DownloadString $GitReleaseApiUrl | ConvertFrom-Json |
    Select-Object -Expand assets | Where-Object { $_.name -Match "MinGit.*64-bit.zip" }
}
$MinGitUrl = $MinGitRelease.browser_download_url -Split " " | Select-Object -First 1
InstallTool -Name "Git" -Url $MinGitUrl -Prefix MinGit*
