param(
  [string]$Version,
  [bool]$UseLatestVersion,
  [object]$AllVersions
)

if ($UseLatestVersion) {
  Confirm-Online
  $NodeVersion = (DownloadString "https://nodejs.org/dist/latest/SHASUMS256.txt").Split([Environment]::NewLine) | Select-Object -First 1 | Select-String "(node-v)([\d\.]+)" | ForEach-Object { $_.Matches.Groups[2] }
} else {
  $NodeVersion = $Version
}

if (!$AllVersions.npm) {
  Confirm-Online
  $LatestNpmInfo = DownloadString "https://registry.npmjs.org/npm/latest" | ConvertFrom-Json
  $NpmVersion = $LatestNpmInfo.version
} else {
  $NpmVersion = $AllVersions.npm
}

$NodeFile = "node.exe"
$NodeDownloadFile = "$DownloadsFolder\node-$NodeVersion.exe"
$NpmFile = "npm-$NpmVersion.tgz"
$NpmDownloadFile = "$DownloadsFolder\$NpmFile"
$NodeInstallFolder = "$ToolsFolder\node-$NodeVersion-npm-$NpmVersion"
$NodeModulesFolder = "$NodeInstallFolder\node_modules"

if (!(Test-Path $NodeDownloadFile)) {
  Confirm-Online
  $NodeDownloadUrl = "https://nodejs.org/dist/v$NodeVersion/win-x64/$NodeFile"
  Out-Info "Downloading Node..."
  DownloadFile $NodeDownloadUrl $NodeDownloadFile
}

if (!(Test-Path $NpmDownloadFile)) {
  Confirm-Online
  $NpmDownloadUrl = "https://registry.npmjs.org/npm/-/npm-$NpmVersion.tgz"
  Out-Info "Downloading npm..."
  DownloadFile $NpmDownloadUrl $NpmDownloadFile
}

if (!(Test-Path "$NodeInstallFolder")) {
  if (!(Test-Path $NodeDownloadFile)) {
    Exit-Offline
  }
  Out-Info "Copying Node..."
  Confirm-Folder $NodeInstallFolder
  Copy-Item $NodeDownloadFile "$NodeInstallFolder\$NodeFile"

  Confirm-Folder $NodeModulesFolder
  Out-Info "Extracting npm..."
  7z x -aoa "$NpmDownloadFile" -o"$NodeModulesFolder" | Out-Null
  7z x -aoa "$NodeModulesFolder\*.tar" -o"$NodeModulesFolder" | Out-Null

  Rename-Item "$NodeModulesFolder\package" "npm"
  Remove-Item -ErrorAction Ignore "$NodeModulesFolder\*.tar"
  Copy-Item "$NodeModulesFolder\npm\bin\*.*" $NodeInstallFolder
}

AddToolToPath $NodeInstallFolder
