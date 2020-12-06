$AnacondaInstallerFile = "Miniconda3-latest-Windows-x86_64.exe"
$AnacondaDownloadUrl = "https://repo.anaconda.com/miniconda/$AnacondaInstallerFile"
$AnacondaDownloadedInstaller = "$DownloadsFolder\$AnacondaInstallerFile"
$AnacondaInstalledFolder = "$ToolsFolder\anaconda"


if (!(Test-Path $AnacondaInstalledFolder)) {
  if (!(Test-Path $AnacondaDownloadedInstaller)) {
    Confirm-Online
    Out-Info "Downloading Anaconda..."
    DownloadFile $AnacondaDownloadUrl $AnacondaDownloadedInstaller
  }
  Out-Info "Extracting Anaconda..."
  & $AnacondaDownloadedInstaller /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=$AnacondaInstalledFolder | Out-Null
}

@"
cmd.exe "/K" $AnacondaInstalledFolder\Scripts\activate.bat $AnacondaInstalledFolder
"@ | Out-FileForce "$AnacondaInstalledFolder\anaconda.cmd"

AddToolToPath $AnacondaInstalledFolder
