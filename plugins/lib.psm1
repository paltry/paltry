Function Out-Title($Message) {
  Write-Host -ForegroundColor "Blue" $Message
}
Function Out-Info($Message) {
  Write-Host -ForegroundColor "Green" $Message
}
Function Out-Warn($Message) {
  Write-Host -ForegroundColor "Yellow" $Message
}
Function Out-Error($Message) {
  Write-Host -ForegroundColor "Red" $Message
}

Function Pause {
  Write-Host "Press any key to continue..."
  $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
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

Function Exit-Error($Message) {
  (New-Object -ComObject Wscript.Shell).Popup($Message, 0, "ERROR!", 16) | Out-Null
  [Environment]::Exit(1)
}

Function Exit-Offline {
  Exit-Error "Required files not downloaded and you are offline"
}

Function Confirm-Online {
  if(!$Online) {
    Exit-Offline
  }
}

Function Get-WebClient {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
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
  AddInstalledTool $ParentFolder
}

Function AddToolToPath($ToolFolder) {
  AddToPath $ToolFolder
  AddInstalledTool $ToolFolder
}

Function AddInstalledTool($ToolFolder) {
  $Global:ToolsInstalled += $ToolFolder
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

Function AddEnvExtension($Property, $Value) {
  $Global:EnvExtensions | Add-Member $Property $Value
}

Function Confirm-Folder($Folder) {
  New-Item -ItemType Directory -Force -Path $Folder | Out-Null
}

Function SetupFolders {
  Confirm-Folder $DownloadsFolder
  Confirm-Folder $TempFolder
  Confirm-Folder $ToolsFolder
  Confirm-Folder $LaunchFolder
  Remove-Item "$LaunchFolder\*"
}

Function Write-Files {
  Out-Console
  Out-ToolsJson
}

Function Out-Console {
  AddEnvExtension "PATH" "$($Global:PathExtensions -Join ';');%PATH%"
  $EnvOutputs = $Global:EnvExtensions.PSObject.Properties | %{ "set $($_.Name)=$($_.Value)" } | Out-String
@"
@echo off
$($EnvOutputs -Join '\n')
cd "$ConfigCwd"
if "%*"=="" (start powershell) else (start %*)
"@ | Out-FileForce "$LaunchFolder\console.cmd"
}

Function Out-ToolsJson {
  [PSCustomObject]@{
    installed = $Global:ToolsInstalled
  } | ConvertTo-Json | Out-FileForce "$ToolsFolder\tools.json"
}