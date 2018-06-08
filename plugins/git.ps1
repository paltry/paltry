param (
  [object]$Config
)

if($Online) {
  $GitReleaseApiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
  $PortableGitRelease = (DownloadString $GitReleaseApiUrl | ConvertFrom-Json) |
    Select-Object -Expand assets | Where { $_.name -Match "PortableGit.+64-bit.+" }
  $PortableGitUrl = $PortableGitRelease.browser_download_url -Split " " | Select-Object -First 1
}
InstallTool -Name "Git" -Url $PortableGitUrl -Prefix PortableGit*

if($Config.repos) {
  $Config.repos.PSObject.Properties | %{
    $RepoFolder = "$ConfigCwd\$($_.Name)"
    if(!(Test-Path $RepoFolder)) {
      $RepoUrl = $_.Value
      git clone $RepoUrl $RepoFolder
    }
  }
}