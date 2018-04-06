param (
  [string]$Version,
  [bool]$UseLatestVersion
)

if($Online) {
  if($UseLatestVersion) {
    $MavenDownloadUrl = Invoke-WebRequest -Uri "https://maven.apache.org/download.cgi" |
      %{ $_.Links } | %{ $_.href } | ?{ $_ -Match "apache-maven-[\d.]+-bin.zip$" }
  } else {
    $MavenDownloadUrl = "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=maven/maven-3/$Version/binaries/apache-maven-$Version-bin.zip"
  }
}
InstallTool -Name "Maven" -Url $MavenDownloadUrl -Prefix apache-maven*

$MavenUserFolder = "$UserProfile\.m2"
$MavenRepo = "$MavenUserFolder\repository"

if(Test-Path $MavenRepo) {
  Out-Info "Cleaning up remote m2 repo data..."
  Get-ChildItem -Recurse $MavenRepo -Include @("_maven.repositories", "_remote.repositories",
    "maven-metadata-local.xml", "*.lastUpdated", "resolver-status.properties") |
    %{ Remove-Item -Force -ErrorAction Ignore $_ }
}
