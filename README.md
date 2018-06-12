# Paltry Portable Environment

## Prerequisites

- Windows 10 (or upgrade to [PowerShell 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616))
- No applications need be preloaded
- No special permissions outside of being able to write to a user folder

## Installation

- Create a local folder for your portable environment (`~\Developer` recommended)
- Download the latest [Paltry ZIP archive](https://github.com/paltry/paltry/archive/master.zip)
- Open the downloaded archive
- Drag the `paltry-master` folder in the archive to the portable environment folder you created above and rename it to `paltry`
- Open the extracted `paltry` folder
- Configure your environment
  - If you have an existing `config.json` already prepared, overwrite the one in the extracted Paltry
  - Otherwise consider [editing the default `config.json`](#configuration) to make it your own at this point
    - You can always customize this later and rerun the build
    - The default config comes with all the tools but some features require additional configuration
- Double click on `build.cmd` in your `paltry` folder
  - If you get a security warning - uncheck _Always ask before opening this file_ and click Run
- Paltry will now build
  - The first time this will take anywhere from 1-15 minutes depending on your selected plugins and network speed
- By default - when the build completes - an explorer window will pop up with various shortcuts
  - Feel free to launch any of the tools from here
  - For bonus points add these as a toolbar
    - Right click on your taskbar
    - _Toolbars_
    - _New toolbar..._
    - Select the same path as the window launched after the build
      - Protip: you can copy the full path from the address bar of each

## Configuration

The only file users should modify is `config.json`. It is intended to encompass all user-configurable behavior. The following is a definition of the supported configuration options.

- `cwd (string)` - The current working directory to use when launching the console.
- `env ({string: string})` - Environment variables to set for the portable environment. Note that `Path` is special since it is appended to by Paltry and so should be extended with the `path` option below.
- `disabled ([string])` - A blacklist of the plugins not to run. Note that nonexistant plugins are ignored. The default config takes advantage of this to list available plugins "commented out" by prefixing them with `//`. Removing the "comment" in this list will actually disable that plugin. If you don't ever intend to disable a plugin feel free to remove it from this list entirely.
- `versions ({string: string})` - Most tools support installing the latest available version except for 7zip, which must have a version set. The `maven`, `node`, and `npm` tools support specifying an exact version here. An empty string value or omitting a key entirely defaults to the latest version.
- `path ([string])` - An array of additional locations to add to your path. Usefully for adding other tools not supported by Paltry that you manually downloaded.
- `scripts ({string: [string]})` - Custom scripts are defined with the name as the key (this becomes the filename/command used to call them) and an array of the lines in the script as the value. Note these will create batch files that are run with the command prompt.
- `git (object)`
  - `ssh (boolean)` - Enabling this will make sure you have SSH keys setup, generating them if needed. When keys are generated, the public key will be printed to the console. Please make sure to add this public key to any git remotes you intend to communicate with using SSH.
  - `repos ({string: string})` - Git repositories you want Paltry to clone automatically on your behalf. The local folder to use is the key with the remote URL as the value.
- `maven (object)`
  - `servers ([string])` - If you use private Maven repos (such as a Nexus server) then add their ids in an array to this property. The build will prompt for your credentials and will save encrypted versions of them to `settings.xml`. Different credentials per server are not supported at this time.

## License

Paltry is MIT licensed. See [LICENSE](LICENSE.md).
