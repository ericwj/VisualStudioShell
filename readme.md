# Overview

This repository contains the `VisualStudioShell` [PowerShell](https://aka.ms/PowerShell) module.

This module uses several components available with *Visual Studio 2015* and later to provide the easiest way to start a **Developer Command Prompt** or a **Visual Studio** instance.

A single command is enough to start a *Developer Command Prompt* or *Visual Studio* for the latest version of *Visual Studio* installed:

```PS
# Start a Developer Command Prompt for the latest (preview) version installed
vshell
# Start the latest (preview) version of the IDE installed
vs
```

These are aliases for the `Enter-VisualStudioShell` and `Start-VisualStudio` functions, respectively.

Optional arguments to these commands as well as additional commands are available to customize the default behavior.

# Installation

The module is available from the [PowerShell Gallery](https://www.powershellgallery.com/packages/VisualStudioShell).

```
Install-Module VisualStudioShell
```

Or as usual it can be downloaded wholesale and manually installed. See the documentation on the *PowerShell Gallery*.

# How To

The commands and their parameters are (mostly) well-documented through the *PowerShell* help system.

Use the following commands to get help.
```PS
Get-Command -Module VisualStudioShell
Get-Help vshell
Get-Help vshell -Detailed
```
etc.

To see information about the actions performed, pick and choose between (combinations of) the `-WhatIf`, `-Verbose` and/or `-Debug` arguments.

To prevent interactive prompts &mdash; mainly to install the `VSSetup` module, use the `-Force` argument.

# How it works

The module just fuses together the functionality of the `VSSetup` module provided by *Microsoft* and the `Microsoft.VisualStudio.DevShell` module included with installations of *Visual Studio*.

* The `VSSetup` module is an alternative for the [`vswhere`](https://github.com/microsoft/vswhere) program and provides richer information in a way more suitable to *PowerShell* consumers to locate installed versions of *Visual Studio*.

* The `Microsoft.VisualStudio.DevShell` exposes the `Enter-VsDevCmd` command. It is a bit of hack around `VsDevCmd.bat` which is still the means of initializing *Developer Command Prompt*. Basically it just runs `VsDevCmd.bat` in a new process, captures its environment by running `set` and then just sets every single environment variable in the *PowerShell* session &mdash; even those that weren't changed.

Especially the latter of these is a bit hard to use.
* It cannot be loaded automatically but must be sourced from the Visual Studio installation directory. This means that the `Enter-VsDevCmd` command is practically useless - it is not available without doing more work than just starting `VsDevCmd` yourself.
* It accepts an opaque string for the arguments it passes to `VsDevCmd.bat` hence *PowerShell* is unable to help building the string and, worse, there is not one clue anywhere about what the string may look like.

This module provides argument completion for the valid arguments and in addition allows any additional arguments to pass through to `Enter-VsDevCmd`.

# The details

To see everything the script does or can do, find the sources on *GitHub*:

* https://github.com/ericwj/VisualStudioShell
* https://github.com/microsoft/vssetup.powershell
* Sources for `Microsoft.VisualStudio.DevShell` are not public.
* Run these commands and inspect `VsDevCmd.bat` and the files in the `vsdevcmd` subfolder.

```PS
$VisualStudio = Get-VisualStudio
vs "$($VisualStudio.InstallationPath)\Common7\Tools"
#or
code "$($VisualStudio.InstallationPath)\Common7\Tools"
```

# Dependencies

Two dependencies are used by this module.

* `VSSetup` available from the [PowerShell Gallery](https://www.powershellgallery.com/packages/VSSetup). The minimum required version is (declared as) `2.2.16` although older versions might work.
* `Microsoft.VisualStudio.DevShell` is part of (recent) *Visual Studio* installations.

The first is automatically installed if it is not already upon running `vshell`. The default behavior is to prompt for confirmation to install the module using the `Install-Package` command. However there is a `-Force` switch with which this behavior can be overridden.

The second is loaded at most once per *PowerShell* session from the *Visual Studio* installation that a *Developer Command Prompt* is first requested for.

By default this module is loaded from one of these locations:
* `$($VisualStudio.InstallationPath)\Common7\Tools\Microsoft.VisualStudio.DevShell.dll`
* `$($VisualStudio.InstallationPath)\Common7\Tools\vsdevshell\Microsoft.VisualStudio.DevShell.dll`
