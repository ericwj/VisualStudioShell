#Requires -Module VSSetup
using module VSSetup
<#
	.Synopsis
	Start a Visual Studio Developer Command Prompt

	.Description
	Finds the latest (preview) version of Visual Studio unless an instance of Visual Studio is provided as an argument and starts a Developer Command prompt for it.

	.Parameter ExcludePrerelease
	Do not allow selection of Preview versions of Visual Studio. (Passed through negated to Get-VSSetupInstance)

	.Parameter Architecture
	The target processor architecture. This is the architecture for compiled binaries/libraries.

	Optional. Valid values are "x86", "amd64", "arm", "arm64". The default is "x86".

	.Parameter HostArchitecture
	The processor architecture of the compiler binaries.

	Optional. Valid values are "x86", "amd64". The default is "x86".

	.Parameter WindowsSdkVersion
	Version of Windows SDK to select.
	- 10.0.xxyyzz.0 : Windows 10 SDK (e.g 10.0.10240.0) [default : Latest Windows 10 SDK]
	- 8.1 : Windows 8.1 SDK
	- none : Do not setup Windows SDK variables.
	For use with build systems that prefer to determine Windows SDK version independently.

	Optional. Valid values are "none", "8.1", "10.0.xxyyzz.0". However if a Visual Studio Setup intance
	is specified, its package list will be used to verify that the version of the SDK that is requested
	is installed.

	.Parameter AppPlatform
	Application Platform Target Type.

	Optional. Valid values are "Desktop", "UWP".
	Desktop : Classic Win32 Apps          [default]
	UWP     : Universal Windows Platform Apps

	.Parameter NoExtensions
	Only scripts from [VS160COMNTOOLS]\VsDevCmd\Core directory are run during initialization.

	.Parameter NoLogo
	Suppress printing of the developer command prompt banner.

	.Parameter Product
	One or more products to select. Wildcards are supported. (Passed through to Select-VSSetupInstance)

	Run `Get-VSSetupInstance | Select-Object Product` to obtain a list of available valid values albeit with a version number.

	.Parameter StartDirectoryMode
	The startup directory mode.

	Optional. Valid values are "none", "auto".

	none : the command prompt will exist in the same current directory as when invoked
	auto : the command prompt will search for [USERPROFILE]\Source and will change directory if it exists.

	If -startdir=mode is not provided, the developer command prompt scripts will
	additionally check for the [VSCMD_START_DIR] environment variable. If not specified,
	the default behavior will be 'none' mode.

	.Parameter Test
	Run smoke tests to verify environment integrity in an already-initialized command prompt.
	Executing with -test will NOT modify the environment, so it must be used in a separate call
	to vsdevcmd.bat (all other parameters should be the same as when the environment was
	initialied)

	.Parameter VisualStudio
	The Visual Studio Setup Instance.

	Use the VSSetup module or Get-VisualStudio CmdLet to obtain this instance.

	.Parameter SkipExistingEnvironmentVariables
	Passed through to Enter-VsDevShell.

	.Parameter StartInPath
	Passed through to Enter-VsDevShell. The default is $PWD.

	.Parameter Force
	Never ask for confirmation interactively. Combining -WhatIf and -Force will still do nothing.

	Used to force installation of the VSSetup module from the Internet.

	.Parameter RemainingArguments
	Receives all parameters not bound to one of the other, named arguments.

	These values will be passed unmodified to Enter-VsDevShell.

#>
function Enter-VisualStudioShell {
	[CmdLetBinding(
		SupportsShouldProcess = $true,
		ConfirmImpact = [System.Management.Automation.ConfirmImpact]::Medium
	)]
	Param(
		[ValidateSet($null, "x86", "amd64", "arm", "arm64")]
		[Alias("arch")]
		[string]$Architecture = $null,

		[ValidateSet($null, "x86", "amd64")]
		[Alias("host_arch")]
		[string]$HostArchitecture = $null,

		[ValidateScript({ Confirm-WindowsSdkVersion -WindowsSdkVersion $_ -AllowNullOrEmpty -VisualStudio $VisualStudio })]
		[Alias("winsdk")]
		[string]$WindowsSdkVersion = $null,

		[ValidateSet($null, "Desktop", "UWP")]
		[Alias("app_platform")]
		[string]$AppPlatform,

		[Alias("no_ext")]
		[switch]$NoExtensions = [switch]::new($false),

		[Alias("no_logo")]
		[switch]$NoLogo = [switch]::new($false),

		[string[]]$Product = $null,

		[ValidateSet($null, "none", "auto")]
		[Alias("startdir")]
		[string]$StartDirectoryMode = $null,

		# [Alias("test")] can't be the same case-insensitively
		[switch]$Test = [switch]::new($false),

		[Microsoft.VisualStudio.Setup.Instance]$VisualStudio = $null,

		[switch]$SkipExistingEnvironmentVariables = [switch]::new($false),
		[string]$StartInPath = $PWD,

		[switch]$Force = [switch]::new($false),

		[switch]$ExcludePrerelease = [switch]::new($false),

		[Parameter(ValueFromRemainingArguments)]
		[object[]]$RemainingArguments = $null
	)
	Process {
		if ($null -eq $VisualStudio) {
			if ($null -eq $Product) {
				$VisualStudio = Get-VisualStudio -ExcludePrerelease:($ExcludePrerelease.IsPresent)
			} else {
				$VisualStudio = Get-VisualStudio -ExcludePrerelease:($ExcludePrerelease.IsPresent) -Product:$Product
			}
		} elseif (-not (Confirm-VisualStudio $VisualStudio)) {
			Write-Error "The Visual Studio parameter is not valid. Remove the parameter or specify a valid value."
			return;
		}
		if (-not (Import-VisualStudioShellModule -VisualStudio $VisualStudio)) {
			Write-Error "Could not load the Visual Studio Shell module."
		}

		$DevCmdArguments = Format-VisualStudioShellArguments `
			-VisualStudio $VisualStudio `
			-Architecture $Architecture `
			-HostArchitecture $HostArchitecture `
			-WindowsSdkVersion $WindowsSdkVersion `
			-AppPlatform $AppPlatform `
			-StartDirectoryMode $StartDirectoryMode `
			-RemainingArguments $RemainingArguments `
			-NoExtensions:($NoExtensions.IsPresent) `
			-NoLogo:($NoLogo.IsPresent) `
			-Test:($Test.IsPresent)
		$target = "{0} [{1}]" -f @(
			$VisualStudio.DisplayName
			$VisualStudio.InstallationName
			$VisualStudio.InstallationPath
		)
		$action = "{0} -{1} '{2}' -{3} '{4}' -{5} '{6}' -{7} '{8}'" -f @(
			"Enter-VsDevShell"
			"VsInstallPath"
			$VisualStudio.InstallationPath
			"SkipExistingEnvironmentVariables"
			$SkipExistingEnvironmentVariables.IsPresent
			"StartInPath"
			$StartInPath
			"DevCmdArguments"
			$DevCmdArguments
		)
		# Since Enter-VsDevShell also SupportsShouldProcess, invoke it even if ShouldProcess returns false but hide the logo
		$ShouldProcess = $PSCmdlet.ShouldProcess($target, $action)
		if (-not $ShouldProcess) {
			if (-not $NoLogo.IsPresent) {
				$DevCmdArguments += " -no_logo"
				$DevCmdArguments = $DevCmdArguments.Trim()
				Write-Verbose "Adding -no_logo because ShouldProcess is false and -NoLogo was not specified."
			}
			if ($StartInPath -ne $PWD.Path) {
				Write-Verbose "Changing StartInPath from '$StartInPath' to '$PWD' because ShouldProcess is false and StartInPath is different from the current working directory."
				$StartInPath = $PWD.Path
			}
		}

		# On older Visual Studios, on PowerShell Core, only the first time, MethodNotFoundException occurs
		while ($true) {
			try {
				Enter-VsDevShell `
					-VsInstallPath $VisualStudio.InstallationPath `
					-SkipExistingEnvironmentVariables:$SkipExistingEnvironmentVariables `
					-StartInPath $StartInPath `
					-DevCmdArguments $DevCmdArguments
				break;
			} catch {
				$e = $_
				$x = $e.Exception
				while ($x -is [System.AggregateException]) { $x = $x.InnerException }
				if ($x -is [System.MissingMethodException] -and ($x.Message -match "GetAccessControl")) {
					$m =
						"Ignoring expected exception {0} with message '{1}' " +
						"because the environment has been successfully initialized."
					$m = $m -f @(
						$x.GetType().Name
						$x.Message
					)
					Write-Verbose $m
					break
				}
				throw
			}
		}
	}
}
