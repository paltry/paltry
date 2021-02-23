if ($Online) {
  $JavaReleaseApiUrl = "https://api.github.com/repos/ojdkbuild/ojdkbuild/releases"
  $JavaRelease = (DownloadString $JavaReleaseApiUrl | ConvertFrom-Json) |
  Select-Object -Expand assets | Where-Object { $_.Name -match "java-11-openjdk-11.+\.windows\.ojdkbuild\.x86_64\.zip$" }
  $JavaDownloadUrl = $JavaRelease.browser_download_url -split " " | Select-Object -First 1
}

InstallTool -Name "JDK" -Url $JavaDownloadUrl -Prefix java* | Out-Null
$JdkInstalledFolder = FindTool java*
AddEnvExtension "JAVA_HOME" $JdkInstalledFolder
