if ($Online) {
  $JavaReleaseApiUrl = "https://api.github.com/repos/ojdkbuild/ojdkbuild/releases/latest"
  $JavaRelease = (DownloadString $JavaReleaseApiUrl | ConvertFrom-Json) |
  Select-Object -Expand assets | Where-Object { $_.Name -match "openjdk-1.8.0.+\.windows\.x86_64\.zip" }
  $JavaDownloadUrl = $JavaRelease.browser_download_url -split " " | Select-Object -First 1
}

InstallTool -Name "JDK" -Url $JavaDownloadUrl -Prefix java*
$JdkInstalledFolder = FindTool java*
AddEnvExtension "JAVA_HOME" $JdkInstalledFolder
