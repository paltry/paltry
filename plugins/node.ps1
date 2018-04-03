if($Online) {
  $NodeFolder = DownloadString "https://nodejs.org/dist/latest/SHASUMS256.txt" |
    %{ ([regex]'node-v[\d\.]+').Matches($_) | %{ $_.Value } } | Select-Object -First 1
  $NodeFile = "node.exe"
  $NodeDownloadUrl = "https://nodejs.org/dist/latest/win-x64/$NodeFile"
  $NodeDownloadFile = "$DownloadsFolder\$NodeFolder.exe"
  $NodeInstallFolder = "$ToolsFolder\$NodeFolder"

  if(!(Test-Path $NodeInstallFolder)) {
    if(!(Test-Path $NodeDownloadFile)) {
      Out-Info "Downloading Node..."
      DownloadFile $NodeDownloadUrl $NodeDownloadFile
    }
    if(!(Test-Path "$NodeInstallFolder\$NodeFile")) {
      Out-Info "Copying Node..."
      Confirm-Folder $NodeInstallFolder
      Copy-Item $NodeDownloadFile "$NodeInstallFolder\$NodeFile"
    }
  }
}

$NodeInstallFolder = FindTool node-*
AddToPath $NodeInstallFolder