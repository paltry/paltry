if($Online) {
  $MavenDownloadUrl = Invoke-WebRequest -Uri "https://maven.apache.org/download.cgi" |
    %{ $_.Links } | %{ $_.href } | ?{ $_ -Match "apache-maven-[\d.]+-bin.zip$" }
}
InstallTool -Name "Maven" -Url $MavenDownloadUrl -Prefix apache-maven*

$MavenUserFolder = "$UserProfile\.m2"
$MavenRepo = "$MavenUserFolder\repository"

if(Test-Path $MavenRepo) {
  Get-ChildItem -Recurse $MavenRepo -Include @("_maven.repositories", "_remote.repositories",
    "maven-metadata-local.xml", "*.lastUpdated", "resolver-status.properties") |
    %{ Remove-Item -Force -ErrorAction Ignore $_ }
}