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
      Confirm-Folder $NodeInstallFolder
      Copy-Item $NodeDownloadFile "$NodeInstallFolder\$NodeFile"
    }

    $LatestNpmInfo = DownloadString "http://registry.npmjs.org/npm/latest" | ConvertFrom-Json
    $NpmDownloadUrl = $LatestNpmInfo.dist.tarball
    $NpmFile = FileForUrl $NpmDownloadUrl
    $NpmDownloadFile = "$DownloadsFolder\$NpmFile"

    if(!(Test-Path $NpmDownloadFile)) {
      Out-Info "Downloading npm..."
      DownloadFile $NpmDownloadUrl $NpmDownloadFile
    }

    $NodeModulesFolder = "$NodeInstallFolder\node_modules"
    if(!(Test-Path $NodeModulesFolder)) {
      Confirm-Folder $NodeModulesFolder
      Out-Info "Extracting npm..."
      7z x -aoa "$NpmDownloadFile" -o"$NodeModulesFolder" | Out-Null
      7z x -aoa "$NodeModulesFolder\*.tar" -o"$NodeModulesFolder" | Out-Null
  
      Rename-Item "$NodeModulesFolder\package" "npm"
      Remove-Item -ErrorAction Ignore "$NodeModulesFolder\*.tar"
      Copy-Item "$NodeModulesFolder\npm\bin\*" $NodeInstallFolder
    }
  }
}

$NodeInstallFolder = FindTool node-*
AddToPath $NodeInstallFolder