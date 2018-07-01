param(
  [object]$Config
)

if ($Online) {
  $GitReleaseApiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
  $PortableGitRelease = (DownloadString $GitReleaseApiUrl | ConvertFrom-Json) |
  Select-Object -Expand assets | Where-Object { $_.Name -match "PortableGit.+64-bit.+" }
  $PortableGitUrl = $PortableGitRelease.browser_download_url -split " " | Select-Object -First 1
}
InstallTool -Name "Git" -Url $PortableGitUrl -Prefix PortableGit*

$SshKeyPath = "$UserProfile\.ssh\id_rsa"
if ($Config.ssh -and !(Test-Path $SshKeyPath)) {
  $GitInstallPath = $JdkInstalledFolder = FindTool PortableGit*
  & $GitInstallPath\usr\bin\ssh-keygen.exe -t rsa -C """""" -N """""" -f $SshKeyPath
  $PublicKey = Get-Content "$SshKeyPath.pub"
  Out-Warn "Make sure to allow your new public key for any remotes that require SSH: $PublicKey"
  Pause
}

if ($Online) {
  if (!(Test-Path "$CurrentFolder\.git")) {
    git init
    git remote add origin https://github.com/paltry/paltry.git
    git fetch
    Move-Item config.json backup.config.json
    git checkout master -f
    Move-Item -Force backup.config.json config.json
  } else {
    Out-Info "Updating Paltry..."
    git fetch
    git merge --ff-only origin/master
  }
}

if ($Config.repos) {
  $Config.repos.PSObject.Properties | ForEach-Object {
    $RepoFolder = "$ConfigCwd\$($_.Name)"
    if (!(Test-Path $RepoFolder)) {
      Confirm-Online
      $RepoUrl = $_.Value
      git clone $RepoUrl $RepoFolder
      if ($LastExitCode) {
        Exit-Error "Failed to clone $RepoUrl! Maybe you need to add your SSH keys?"
      }
    }
  }
}
