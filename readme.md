# Overview

This repository contains the `VisualStudioShell` PowerShell module.

This module uses several components available with Visual Studio 2015 and later to provide the easiest way to start a Developer Command Prompt or a Visual Studio instance.

A single command is enough to start a Developer Command Prompt or the IDE for the most recent version of Visual Studio installed:

```PS
# Start a Developer Command Prompt for the latest (preview) version installed
vshell
# Start the latest (preview) version of the IDE installed
vs
```

These are aliases for the `Enter-VisualStudioShell` and `Start-VisualStudio` functions, respectively.

Optional arguments to these commands as well as additional commands are available to customize the default behavior.

# How To

The commands and their parameters are (mostly) well-documented through the PowerShell help system.

Use the following commands to get help.
```PS
Get-Command -Module VisualStudioShell
Get-Help vshell
Get-Help vshell -Detailed
```
etc.

To see very detailed information about the actions performed, use the `-WhatIf` argument.

```PS
vshell -WhatIf
```

# Dependencies

Two dependencies are used by this module.

* `VSSetup` available from the [PowerShell Gallery](https://www.powershellgallery.com/packages/VSSetup). The minimum required version is (declared as) `2.2.16` although older versions might work.
* `Microsoft.VisualStudio.DevShell` is part of (recent) Visual Studio installations.

The first is automatically installed if it is not already upon running `vshell`. The default behavior is to prompt for confirmation to install the module using the `Install-Package` command. However there is a `-Force` switch with which this behavior can be overridden.

The second is loaded at most once per PowerShell session from the Visual Studio installation that a Developer Command Prompt is first requested for. This is not a fully-fledged PowerShell module and unloading it appears to be impossible.

By default this module is loaded from one of these locations:
* `$($VisualStudio.InstallationPath)\Common7\Tools\Microsoft.VisualStudio.DevShell.dll`
* `$($VisualStudio.InstallationPath)\Common7\Tools\vsdevshell\Microsoft.VisualStudio.DevShell.dll`
