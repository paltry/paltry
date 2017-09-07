if($Online) {
  $EclipseDownloadUrl = Invoke-WebRequest -Uri "https://www.eclipse.org/downloads/eclipse-packages" |
    %{ $_.Links } | %{ $_.href } | ?{ $_ -Match "eclipse-jee-.+x86_64.zip$" } |
    %{ "https://www.eclipse.org$_&mirror_id=1" }
}

$EclipseWorkspace = "$CurrentFolder\eclipse-workspace"

InstallTool -Name "Eclipse" -Url $EclipseDownloadUrl -Prefix eclipse-jee*
Add-Launch -Name "Eclipse" -Target "$(FindTool eclipse-jee*)\eclipse.exe" -Arguments "-data ""$EclipseWorkspace"""

if(!(Test-Path $EclipseWorkspace)) {
@"
eclipse.preferences.version=1
showIntro=false
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.ui.prefs"
@"
<?xml version="1.0" encoding="UTF-8"?>
<state reopen="false"/>
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.ui.intro\introstate"
@"
editor_save_participant_org.eclipse.jdt.ui.postsavelistener.cleanup=true
sp_cleanup.add_default_serial_version_id=true
sp_cleanup.add_generated_serial_version_id=false
sp_cleanup.add_missing_annotations=true
sp_cleanup.add_missing_deprecated_annotations=true
sp_cleanup.add_missing_methods=false
sp_cleanup.add_missing_nls_tags=false
sp_cleanup.add_missing_override_annotations=true
sp_cleanup.add_missing_override_annotations_interface_methods=true
sp_cleanup.add_serial_version_id=false
sp_cleanup.always_use_blocks=true
sp_cleanup.always_use_parentheses_in_expressions=false
sp_cleanup.always_use_this_for_non_static_field_access=true
sp_cleanup.always_use_this_for_non_static_method_access=false
sp_cleanup.convert_functional_interfaces=true
sp_cleanup.convert_to_enhanced_for_loop=true
sp_cleanup.correct_indentation=false
sp_cleanup.format_source_code=true
sp_cleanup.format_source_code_changes_only=false
sp_cleanup.insert_inferred_type_arguments=false
sp_cleanup.make_local_variable_final=true
sp_cleanup.make_parameters_final=false
sp_cleanup.make_private_fields_final=true
sp_cleanup.make_type_abstract_if_missing_method=false
sp_cleanup.make_variable_declarations_final=false
sp_cleanup.never_use_blocks=false
sp_cleanup.never_use_parentheses_in_expressions=true
sp_cleanup.on_save_use_additional_actions=true
sp_cleanup.organize_imports=true
sp_cleanup.qualify_static_field_accesses_with_declaring_class=false
sp_cleanup.qualify_static_member_accesses_through_instances_with_declaring_class=true
sp_cleanup.qualify_static_member_accesses_through_subtypes_with_declaring_class=true
sp_cleanup.qualify_static_member_accesses_with_declaring_class=false
sp_cleanup.qualify_static_method_accesses_with_declaring_class=false
sp_cleanup.remove_private_constructors=true
sp_cleanup.remove_redundant_type_arguments=true
sp_cleanup.remove_trailing_whitespaces=false
sp_cleanup.remove_trailing_whitespaces_all=true
sp_cleanup.remove_trailing_whitespaces_ignore_empty=false
sp_cleanup.remove_unnecessary_casts=true
sp_cleanup.remove_unnecessary_nls_tags=false
sp_cleanup.remove_unused_imports=false
sp_cleanup.remove_unused_local_variables=false
sp_cleanup.remove_unused_private_fields=true
sp_cleanup.remove_unused_private_members=false
sp_cleanup.remove_unused_private_methods=true
sp_cleanup.remove_unused_private_types=true
sp_cleanup.sort_members=false
sp_cleanup.sort_members_all=false
sp_cleanup.use_anonymous_class_creation=false
sp_cleanup.use_blocks=false
sp_cleanup.use_blocks_only_for_return_and_throw=false
sp_cleanup.use_lambda=true
sp_cleanup.use_parentheses_in_expressions=false
sp_cleanup.use_this_for_non_static_field_access=true
sp_cleanup.use_this_for_non_static_field_access_only_if_necessary=false
sp_cleanup.use_this_for_non_static_method_access=true
sp_cleanup.use_this_for_non_static_method_access_only_if_necessary=true
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.jdt.ui.prefs"
@"
decorator_filetext_decoration={name}
decorator_foldertext_decoration={name}
decorator_projecttext_decoration={name} [{repository }{branch}{ branch_status}]
decorator_show_dirty_icon=true
decorator_submoduletext_decoration={name} [{branch}{ branch_status}]{ short_message}
eclipse.preferences.version=1
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.egit.ui.prefs"
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
@"
org.eclipse.ui.commands=<?xml version\="1.0" encoding\="UTF-8"?>\r\n<org.eclipse.ui.commands>\r\n<keyBinding commandId\="org.eclipse.m2e.core.pomFileAction.run" contextId\="org.eclipse.ui.contexts.window" keyConfigurationId\="org.eclipse.ui.defaultAcceleratorConfiguration" keySequence\="CTRL+SHIFT+B"/>\r\n<keyBinding contextId\="org.eclipse.ui.contexts.window" keyConfigurationId\="org.eclipse.ui.defaultAcceleratorConfiguration" keySequence\="ALT+SHIFT+X M"/>\r\n<keyBinding contextId\="org.eclipse.ui.contexts.window" keyConfigurationId\="org.eclipse.ui.defaultAcceleratorConfiguration" keySequence\="CTRL+SHIFT+B"/>\r\n<keyBinding commandId\="org.eclipse.debug.ui.commands.ToggleBreakpoint" contextId\="org.eclipse.ui.contexts.window" keyConfigurationId\="org.eclipse.ui.defaultAcceleratorConfiguration" keySequence\="SHIFT+B"/>\r\n</org.eclipse.ui.commands>
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.ui.workbench.prefs"
@"
Console.limitConsoleOutput=false
"@ | Out-FileForce "$EclipseWorkspace\.metadata\.plugins\org.eclipse.core.runtime\.settings\org.eclipse.debug.ui.prefs"
}