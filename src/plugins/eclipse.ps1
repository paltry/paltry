param(
  [object]$Config
)

if ($Online) {
  $EclipseDownloadUrl = Get-WebRequest "https://www.eclipse.org/downloads/packages" |
  ForEach-Object { $_.Links } | ForEach-Object { $_.href } |
  Where-Object { $_ -match "eclipse-java-.+x86_64.zip$" } |
  ForEach-Object { "$_&mirror_id=1" } |
  ForEach-Object { $_ -replace "about://","https://" }
}

$EclipseWorkspace = "$CurrentFolder\eclipse-workspace"

InstallTool -Name "Eclipse" -Url $EclipseDownloadUrl -Prefix eclipse-java* | Out-Null
Add-Launch -Name "Eclipse" -Target "$(FindTool eclipse-java*)\eclipse.exe" -Arguments "-data ""$EclipseWorkspace"""

if ($Config.skipIntro) {
  @"
eclipse.preferences.version=1
showIntro=false
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.ui.prefs"
}

if ($Config.unlimitedConsoleOutput) {
  @"
Console.limitConsoleOutput=false
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.debug.ui.prefs"
}

if ($Config.gitIconDecorations) {
  @"
eclipse.preferences.version=1
decorator_filetext_decoration={name}
decorator_foldertext_decoration={name}
decorator_projecttext_decoration={name} [{repository }{branch}{ branch_status}]
decorator_show_dirty_icon=true
decorator_submoduletext_decoration={name} [{branch}{ branch_status}]{ short_message}
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.egit.ui.prefs"
}

if ($Config.cleanInstallMavenLaunchConfig) {
  @"
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<launchConfiguration type="org.eclipse.m2e.Maven2LaunchConfigurationType">
  <booleanAttribute key="M2_DEBUG_OUTPUT" value="false"/>
  <stringAttribute key="M2_GOALS" value="clean install"/>
  <booleanAttribute key="M2_NON_RECURSIVE" value="false"/>
  <booleanAttribute key="M2_OFFLINE" value="false"/>
  <stringAttribute key="M2_PROFILES" value=""/>
  <listAttribute key="M2_PROPERTIES"/>
  <stringAttribute key="M2_RUNTIME" value="EMBEDDED"/>
  <booleanAttribute key="M2_SKIP_TESTS" value="false"/>
  <intAttribute key="M2_THREADS" value="1"/>
  <booleanAttribute key="M2_UPDATE_SNAPSHOTS" value="false"/>
  <stringAttribute key="M2_USER_SETTINGS" value=""/>
  <booleanAttribute key="M2_WORKSPACE_RESOLUTION" value="false"/>
  <stringAttribute key="org.eclipse.jdt.launching.WORKING_DIRECTORY" value="`${project_loc}"/>
</launchConfiguration>
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.debug.core\.launches\Clean Install Current Project.launch"
}
