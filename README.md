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
  - Otherwise consider editing the default `config.json` to make it your own at this point
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
