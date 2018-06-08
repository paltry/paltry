param (
  [object]$Config
)

if($Online) {
  $GitReleaseApiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
  $PortableGitRelease = (DownloadString $GitReleaseApiUrl | ConvertFrom-Json) |
    Select-Object -Expand assets | Where { $_.name -Match "PortableGit.+64-bit.+" }
  $PortableGitUrl = $PortableGitRelease.browser_download_url -Split " " | Select-Object -First 1
}
InstallTool -Name "Git" -Url $PortableGitUrl -Prefix PortableGit*

$SshKeyPath = "$UserProfile\.ssh\id_rsa"
if($Config.ssh -And !(Test-Path $SshKeyPath)) {
  $GitInstallPath = $JdkInstalledFolder = FindTool PortableGit*
  &$GitInstallPath\usr\bin\ssh-keygen.exe -t rsa -C """""" -N """""" -f $SshKeyPath
  $PublicKey = Get-Content "$SshKeyPath.pub"
  Out-Warn "Make sure to allow your new public key for any remotes that require SSH: $PublicKey"
  Pause
}

if($Config.repos) {
  $Config.repos.PSObject.Properties | %{
    $RepoFolder = "$ConfigCwd\$($_.Name)"
    if(!(Test-Path $RepoFolder)) {
      $RepoUrl = $_.Value
      git clone $RepoUrl $RepoFolder
      if($LastExitCode) {
        Exit-Error "Failed to clone $RepoUrl! Maybe you need to add your SSH keys?"
      }
    }
  }
}