if($Online) {
  $JdkUrl = DownloadString "https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html" |
    %{ ([regex]'http.+-windows-x64.exe').Matches($_) | %{ $_.Value } }
  $JceUrl = "https://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
  $JdkFile = $JdkUrl.Split("/") | Select-Object -Last 1
  $JdkFolder = [io.path]::GetFileNameWithoutExtension($JdkFile)
  $JdkInstallerFile = "$DownloadsFolder\$JdkFile"
  $JceFile = "$DownloadsFolder\jce_policy-8.zip"
  $JdkInstallerFolder = "$TempFolder\$JdkFolder"
  $JdkInstalledFolder = "$ToolsFolder\$JdkFolder"
  if(!(Test-Path $JdkInstalledFolder)) {
    if(!(Test-Path $JdkInstallerFile)) {
      Confirm-Online
      Out-Info "Downloading JDK..."
      $WebClient = Get-WebClient
      $WebClient.Headers.Set("Cookie", "oraclelicense=accept-securebackup-cookie")
      $WebClient.DownloadFile($JdkUrl, $JdkInstallerFile)
      $WebClient.DownloadFile($JceUrl, $JceFile)
    }
    Out-Info "Extracting JDK..."
    Remove-Item -Recurse -Force -ErrorAction Ignore $JdkInstallerFolder
    7z x "$JdkInstallerFile" -o"$JdkInstallerFolder" | Out-Null
    $ToolsZipArchive = Get-ChildItem -Recurse -Path $JdkInstallerFolder |
      Sort Length -Descending | Select-Object -First 1 | %{ $_.FullName }
    7z x "$ToolsZipArchive" -o"$JdkInstallerFolder" | Out-Null
    7z x "$JdkInstallerFolder\tools.zip" -o"$JdkInstalledFolder" | Out-Null
    $Unpack200 = "$JdkInstalledFolder\bin\unpack200"
    Get-ChildItem -Recurse -Include *.pack -Path $JdkInstalledFolder |
      %{ &$Unpack200 -r "$_" "$($_.Directory)\$([io.path]::GetFileNameWithoutExtension($_)).jar" }
    7z x "$JceFile" -o"$JdkInstallerFolder" | Out-Null
    Get-ChildItem -Path "$JdkInstallerFolder\UnlimitedJCEPolicyJDK8" -Filter *.jar |
      Move-Item -Force -Destination "$JdkInstalledFolder\jre\lib\security"
    Remove-Item -Recurse -Force -ErrorAction Ignore $JdkInstallerFolder
  }
}

$JdkInstalledFolder = FindTool jdk*
FindBinAndAddToPath $JdkInstalledFolder
