Function Out-Info($Message) {
  Write-Host -ForegroundColor "Green" $Message
}
Function Out-Warn($Message) {
  Write-Host -ForegroundColor "Yellow" $Message
}
Function Out-Error($Message) {
  Write-Host -ForegroundColor "Red" $Message
}

Function Out-FileForce($Path) {
  Process {
    if(Test-Path $path) {
      Out-File -Force -FilePath $Path -InputObject $_
    } else {
      New-Item -Force -Path $Path -Value $_ -Type File | Out-Null
    }
  }
}

Function Confirm-Online {
  if(!$Online) {
    $ErrorMessage = "Required files not downloaded and you are offline"
    (New-Object -ComObject Wscript.Shell).Popup($ErrorMessage, 0, "ERROR!", 16)
    exit 1
  }
}

Function Get-WebClient {
  $WebClient = New-Object System.Net.WebClient
  $WebClient.Headers.Add("User-Agent", "PowerShell")
  return $WebClient
}

Function DownloadString($Url) {
  $WebClient = Get-WebClient
  return $WebClient.DownloadString($Url)
}

Function DownloadFile($Url, $Path) {
  $WebClient = Get-WebClient
  return $WebClient.DownloadFile($Url, $Path)
}

Function FileForUrl($Url) {
  $File = $Url.Split("/") | Select-Object -Last 1
  return $File
}

Function FindTool($Prefix) {
  return Get-ChildItem $ToolsFolder -Filter $Prefix |
    Sort-Object Name -Descending | Select-Object -First 1 | %{ $_.FullName }
}

Function FindBin($ParentFolder) {
  $BinFolder = Get-ChildItem -Recurse "$ParentFolder" -Include @("*.exe", "*.cmd") |
    Sort-Object FullName | Select-Object -First 1 | %{ $_.Directory.FullName }
  return $BinFolder
}

Function FindBinAndAddToPath($ParentFolder) {
  $BinFolder = FindBin $ParentFolder
  AddToPath $BinFolder
}

Function AddToPath($BinFolder) {
  $Global:PathExtensions += $BinFolder
  $Env:Path = "$BinFolder;$Env:Path"
}

Function InstallTool($Name, $Url, $Prefix, $ToolFile) {
  if($Online) {
    if(!($ToolFile)) {
      $ToolFile = $Url.Split("/") | Select-Object -Last 1
    }
    $ToolFolder = [io.path]::GetFileNameWithoutExtension($ToolFile)
    if(!($ToolFile.Contains("."))) {
      $Url = [System.Net.WebRequest]::Create($Url).GetResponse().ResponseUri.AbsoluteUri
      $ToolFile = $Url.Split("/") | Select-Object -Last 1
      $ToolFolder = [io.path]::GetFileNameWithoutExtension($ToolFile)
    }
    $DownloadedFile = "$DownloadsFolder\$ToolFile"
    $ExtractedFolder = "$TempFolder\$Name"
    $InstalledFolder = "$ToolsFolder\$ToolFolder"
  } else {
    $InstalledFolder = FindTool $Prefix
    if(!$InstalledFolder) {
      Confirm-Online
    }
  }
  if(!(Test-Path $InstalledFolder)) {
    if(!(Test-Path $DownloadedFile)) {
      Confirm-Online
      Out-Info "Downloading $Name..."
      DownloadFile $Url $DownloadedFile
    }
    Out-Info "Extracting $Name..."
    Remove-Item -Recurse -ErrorAction Ignore $ExtractedFolder
    7z x "$DownloadedFile" -o"$ExtractedFolder" | Out-Null
    $ExtractedContents = Get-ChildItem $ExtractedFolder
    if($ExtractedContents.Length -eq 1 -And $ExtractedContents[0].PSIsContainer) {
      Move-Item $ExtractedContents[0].FullName $InstalledFolder
      Remove-Item $ExtractedFolder
    } else {
      Move-Item $ExtractedFolder $InstalledFolder
    }
  }

  FindBinAndAddToPath $InstalledFolder
}

Function Add-Launch($Name, $Target, $Arguments) {
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut("$LaunchFolder\$Name.lnk")
  $Shortcut.TargetPath = "$LaunchFolder\console.cmd"
  $Shortcut.Arguments = "$Target $Arguments"
  $Shortcut.IconLocation = "$Target, 0"
  $Shortcut.Save()
}

Function Confirm-Folder($Folder) {
  New-Item -ItemType Directory -Force -Path $Folder | Out-Null
}

Function SetupFolders() {
  Confirm-Folder $DownloadsFolder
  Confirm-Folder $TempFolder
  Confirm-Folder $ToolsFolder
  Confirm-Folder $LaunchFolder
  Remove-Item "$LaunchFolder\*"
}

Function Out-Console() {
@"
@echo off
set PATH=$($Global:PathExtensions -Join ';');%PATH%
cd "$CurrentFolder"
if "%*"=="" (start powershell) else (start %*)
"@ | Out-FileForce "$LaunchFolder\console.cmd"
}
