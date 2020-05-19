param(
  [string]$Version,
  [bool]$UseLatestVersion
)

if ($UseLatestVersion) {
  Confirm-Online
  $RubyReleaseApiUrl = "https://api.github.com/repos/oneclick/rubyinstaller2/releases/latest"
  $RubyVersion = (DownloadString $RubyReleaseApiUrl | ConvertFrom-Json) |
  ForEach-Object { $_.tag_name -replace "RubyInstaller-","" }
} else {
  $RubyVersion = $Version
}

$RubyDownloadUrl = "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-$RubyVersion/rubyinstaller-$RubyVersion-x64.7z"
InstallTool -Name "Ruby" -Url $RubyDownloadUrl -Prefix rubyinstaller*
ridk install 3