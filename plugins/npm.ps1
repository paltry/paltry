param(
  [string]$Version,
  [bool]$UseLatestVersion
)

if ($UseLatestVersion) {
  Confirm-Online
  $LatestNpmInfo = DownloadString "https://registry.npmjs.org/npm/latest" | ConvertFrom-Json
  $NpmVersion = $LatestNpmInfo.version
} else {
  $NpmVersion = $Version
}

$NpmFile = "npm-$NpmVersion.tgz"
$NpmDownloadFile = "$DownloadsFolder\$NpmFile"

if (!(Test-Path $NpmDownloadFile)) {
  Confirm-Online
  $NpmDownloadUrl = "https://registry.npmjs.org/npm/-/npm-$NpmVersion.tgz"
  Out-Info "Downloading npm..."
  DownloadFile $NpmDownloadUrl $NpmDownloadFile
}

$NpmInstallFolder = "$ToolsFolder\npm-$NpmVersion"
$NodeModulesFolder = "$NpmInstallFolder\node_modules"

if (!(Test-Path $NodeModulesFolder)) {
  Confirm-Folder $NodeModulesFolder
  Out-Info "Extracting npm..."
  7z x -aoa "$NpmDownloadFile" -o"$NodeModulesFolder" | Out-Null
  7z x -aoa "$NodeModulesFolder\*.tar" -o"$NodeModulesFolder" | Out-Null

  Rename-Item "$NodeModulesFolder\package" "npm"
  Remove-Item -ErrorAction Ignore "$NodeModulesFolder\*.tar"
  Copy-Item "$NodeModulesFolder\npm\bin\*.*" $NpmInstallFolder
}

AddToolToPath $NpmInstallFolder
