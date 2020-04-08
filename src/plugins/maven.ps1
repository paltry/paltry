param(
  [string]$Version,
  [bool]$UseLatestVersion,
  [object]$Config
)

if ($Online -and $UseLatestVersion) {
  $Version = Get-WebRequest "https://archive.apache.org/dist/maven/maven-3" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.innerText -replace "/","" } | Where-Object { $_ -match "3." } |
  Sort-Object -Descending | Select-Object -First 1
}
$MavenDownloadUrl = "https://archive.apache.org/dist/maven/maven-3/$Version/binaries/apache-maven-$Version-bin.zip"
InstallTool -Name "Maven" -Url $MavenDownloadUrl -Prefix apache-maven*

$MavenUserFolder = "$UserProfile\.m2"
$MavenSettings = "$MavenUserFolder\settings.xml"
$MavenSecuritySettings = "$MavenUserFolder\settings-security.xml"
$MavenRepo = "$MavenUserFolder\repository"
Confirm-Folder $MavenUserFolder

if ($Config.servers -and $Config.servers.Length) {
  if (!(Test-Path $MavenSecuritySettings)) {
    Out-Info "Encrypting Master Password For Maven..."
    $MasterPasswordCredential = Get-Credential -Credential "Master Password"
    $MasterPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($MasterPasswordCredential.Password)
    )
    $EncryptedMasterPassword = mvn --encrypt-master-password """$MasterPassword"""
    @"
    <settingsSecurity>
      <master>$EncryptedMasterPassword</master>
    </settingsSecurity>
"@ | Out-File $MavenSecuritySettings
  }
  if (!(Test-Path $MavenSettings)) {
    Out-Info "Encrypting Server Passwords For Maven..."
    $ServerCredential = Get-Credential -Credential ""
    $ServerUserName = $ServerCredential.UserName
    $ServerPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ServerCredential.Password)
    )
    $EncryptedServerPassword = mvn --encrypt-password """$ServerPassword"""
    $Config.servers | ForEach-Object { @"
      <server>
        <id>$_</id>
        <username>$ServerUserName</username>
        <password>$EncryptedServerPassword</password>
      </server>
"@ } | Out-String | ForEach-Object { @"
      <settings>
        <servers>
          $_
        </servers>
      </settings>
"@ } | Out-File $MavenSettings
  }
}

if ((Test-Path $MavenRepo) -and $Config.cleanup) {
  Out-Info "Cleaning up remote m2 repo data..."
  Get-ChildItem -Recurse $MavenRepo -Include @("_maven.repositories","_remote.repositories",
    "maven-metadata-local.xml","*.lastUpdated","resolver-status.properties") |
  ForEach-Object { Remove-Item -Force -ErrorAction Ignore $_ }
}
