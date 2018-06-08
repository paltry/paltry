param (
  [string]$Version,
  [bool]$UseLatestVersion
)

 if($UseLatestVersion) {
  Confirm-Online
  $NodeVersion = "latest"
  $NodeFolder = DownloadString "https://nodejs.org/dist/latest/SHASUMS256.txt" |
    %{ ([regex]'node-v[\d\.]+').Matches($_) | %{ $_.Value } } | Select-Object -First 1
} else {
  $NodeVersion ="v$Version"
  $NodeFolder = "node-$NodeVersion"
}

$NodeFile = "node.exe"
$NodeDownloadFile = "$DownloadsFolder\$NodeFolder.exe"
$NodeInstallFolder = "$ToolsFolder\$NodeFolder"
$NodeDownloadUrl = "https://nodejs.org/dist/$NodeVersion/win-x64/$NodeFile"

if(!(Test-Path $NodeDownloadFile)) {
  Confirm-Online
  Out-Info "Downloading Node..."
  DownloadFile $NodeDownloadUrl $NodeDownloadFile
}

if(!(Test-Path "$NodeInstallFolder\$NodeFile")) {
  if(!(Test-Path $NodeDownloadFile)) {
    Exit-Offline
  }
  Out-Info "Copying Node..."
  Confirm-Folder $NodeInstallFolder
  Copy-Item $NodeDownloadFile "$NodeInstallFolder\$NodeFile"
}

FindBinAndAddToPath $NodeInstallFolder