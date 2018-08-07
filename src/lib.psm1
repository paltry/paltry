function Out-Title ($Message) {
  Write-Host -ForegroundColor "Blue" $Message
}
function Out-Info ($Message) {
  Write-Host -ForegroundColor "Green" $Message
}
function Out-Warn ($Message) {
  Write-Host -ForegroundColor "Yellow" $Message
}
function Out-Error ($Message) {
  Write-Host -ForegroundColor "Red" $Message
}

function Pause {
  Write-Host "Press any key to continue..."
  $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

function Out-FileForce ($Path) {
  process {
    if (Test-Path $path) {
      [IO.File]::WriteAllLines($Path,$_)
    } else {
      New-Item -Force -Path $Path -Value $_ -Type File | Out-Null
    }
  }
}

function Exit-Error ($Message) {
  (New-Object -ComObject Wscript.Shell).Popup($Message,0,"ERROR!",16) | Out-Null
  [Environment]::Exit(1)
}

function Exit-Offline {
  Exit-Error "Required files not downloaded and you are offline"
}

function Confirm-Online {
  if (!$Online) {
    Exit-Offline
  }
}

function Get-WebClient {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $WebClient = New-Object System.Net.WebClient
  $WebClient.Headers.Add("User-Agent","PowerShell")
  return $WebClient
}

function DownloadString ($Url) {
  $WebClient = Get-WebClient
  return $WebClient.DownloadString($Url)
}

function DownloadFile ($Url,$Path) {
  $WebClient = Get-WebClient
  return $WebClient.DownloadFile($Url,$Path)
}

function Get-WebRequest ($Url) {
  $HtmlResponse = DownloadString ($Url)
  $RawResponse = [System.Text.Encoding]::Unicode.GetBytes($HtmlResponse)
  $Html = New-Object -Com "HTMLFile"
  try {
    $Html.write($RawResponse)
  }
  catch {
    # Older versions of PowerShell
    $Html.IHTMLDocument2_write($RawResponse)
  }
  return $Html
}

function FileForUrl ($Url) {
  $File = $Url.Split("/") | Select-Object -Last 1
  return $File
}

function FindTool ($Prefix) {
  return Get-ChildItem $ToolsFolder -Filter $Prefix |
  Sort-Object Name -Descending | Select-Object -First 1 | ForEach-Object { $_.FullName }
}

function FindBin ($ParentFolder) {
  $BinFolder = Get-ChildItem -Recurse "$ParentFolder" -Include @("*.exe","*.cmd") |
  Sort-Object FullName | Select-Object -First 1 | ForEach-Object { $_.Directory.FullName }
  return $BinFolder
}

function FindBinAndAddToPath ($ParentFolder) {
  $BinFolder = FindBin $ParentFolder
  AddToPath $BinFolder
  AddInstalledTool $ParentFolder
}

function AddToolToPath ($ToolFolder) {
  AddToPath $ToolFolder
  AddInstalledTool $ToolFolder
}

function AddInstalledTool ($ToolFolder) {
  $Global:ToolsInstalled += $ToolFolder
}

function AddToPath ($BinFolder) {
  $Global:PathExtensions += $BinFolder
  $Env:Path = "$BinFolder;$Env:Path"
}

function InstallTool ($Name,$Url,$Prefix,$ToolFile) {
  if ($Online) {
    if (!($ToolFile)) {
      $ToolFile = $Url.Split("/") | Select-Object -Last 1
    }
    $ToolFolder = [io.path]::GetFileNameWithoutExtension($ToolFile)
    if (!($ToolFile.Contains("."))) {
      $Url = [System.Net.WebRequest]::Create($Url).GetResponse().ResponseUri.AbsoluteUri
      $ToolFile = $Url.Split("/") | Select-Object -Last 1
      $ToolFolder = [io.path]::GetFileNameWithoutExtension($ToolFile)
    }
    $DownloadedFile = "$DownloadsFolder\$ToolFile"
    $ExtractedFolder = "$TempFolder\$Name"
    $InstalledFolder = "$ToolsFolder\$ToolFolder"
  } else {
    $InstalledFolder = FindTool $Prefix
    if (!$InstalledFolder) {
      Confirm-Online
    }
  }
  if (!(Test-Path $InstalledFolder)) {
    if (!(Test-Path $DownloadedFile)) {
      Confirm-Online
      Out-Info "Downloading $Name..."
      DownloadFile $Url $DownloadedFile
    }
    Out-Info "Extracting $Name..."
    Remove-Item -Recurse -ErrorAction Ignore $ExtractedFolder
    7z x "$DownloadedFile" -o"$ExtractedFolder"
    $ExtractedContents = Get-ChildItem $ExtractedFolder
    if ($ExtractedContents.Length -eq 1 -and $ExtractedContents[0].PSIsContainer) {
      Copy-Item $ExtractedContents[0].FullName -Destination $InstalledFolder -Recurse
    } else {
      Copy-Item $ExtractedFolder -Destination $InstalledFolder -Recurse
    }
    Remove-Item -Recurse $ExtractedFolder
  }

  FindBinAndAddToPath $InstalledFolder
}

function Add-Launch ($Name,$Target,$Arguments) {
  $WshShell = New-Object -ComObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut("$LaunchFolder\$Name.lnk")
  $Shortcut.TargetPath = "$LaunchFolder\console.cmd"
  $Shortcut.Arguments = "$Target $Arguments"
  $Shortcut.IconLocation = "$Target, 0"
  $Shortcut.Save()
}

function AddEnvExtension ($Name,$Value) {
  $Global:EnvExtensions += "set $Name=$Value"
}

function Confirm-Folder ($Folder) {
  New-Item -ItemType Directory -Force -Path $Folder | Out-Null
}

function SetupFolders {
  Confirm-Folder $DownloadsFolder
  Confirm-Folder $TempFolder
  Confirm-Folder $ToolsFolder
  Confirm-Folder $LaunchFolder
  Remove-Item "$LaunchFolder\*"
}

function Write-Files {
  Out-Console
  Out-ToolsJson
}

function Out-Console {
  AddEnvExtension "PATH" "$($Global:PathExtensions -Join ';');%PATH%"
  @"
@echo off
$(($Global:EnvExtensions | Out-String) -Join '\n')
cd "$ConfigCwd"
if "%*"=="" (start powershell) else (start %*)
"@ | Out-FileForce "$LaunchFolder\console.cmd"
}

function Out-Json ($Path) {
  process {
    $_ | ConvertTo-Json -Depth 100 | Out-FileForce $Path
  }
}

function Out-ToolsJson {
  [pscustomobject]@{
    installed = $Global:ToolsInstalled
  } | Out-Json "$ToolsFolder\tools.json"
}
