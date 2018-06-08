param(
  [string]$Version,
  [bool]$UseLatestVersion
)

if ($Online -and $UseLatestVersion) {
  $Version = Invoke-WebRequest -Uri "https://archive.apache.org/dist/maven/maven-3" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.innerText -replace "/","" } | Where-Object { $_ -match "3." } |
  Sort-Object -Descending | Select-Object -First 1
}
$MavenDownloadUrl = "https://archive.apache.org/dist/maven/maven-3/$Version/binaries/apache-maven-$Version-bin.zip"
InstallTool -Name "Maven" -Url $MavenDownloadUrl -Prefix apache-maven*

$MavenUserFolder = "$UserProfile\.m2"
$MavenRepo = "$MavenUserFolder\repository"

if (Test-Path $MavenRepo) {
  Out-Info "Cleaning up remote m2 repo data..."
  Get-ChildItem -Recurse $MavenRepo -Include @("_maven.repositories","_remote.repositories",
    "maven-metadata-local.xml","*.lastUpdated","resolver-status.properties") |
  ForEach-Object { Remove-Item -Force -ErrorAction Ignore $_ }
}
