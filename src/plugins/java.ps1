if ($Online) {
  $JavaReleaseApiUrl = "https://api.github.com/repos/AdoptOpenJDK/openjdk8-binaries/releases/latest"
  $JavaRelease = (DownloadString $JavaReleaseApiUrl | ConvertFrom-Json) |
  Select-Object -Expand assets | Where-Object { $_.Name -match "jdk_x64_windows_.+\.zip" }
  $JavaDownloadUrl = $JavaRelease.browser_download_url -split " " | Select-Object -First 1
}

InstallTool -Name "JDK" -Url $JavaDownloadUrl -Prefix OpenJDK*
$JdkInstalledFolder = FindTool OpenJDK*
FindBinAndAddToPath $JdkInstalledFolder
AddEnvExtension "JAVA_HOME" $JdkInstalledFolder
