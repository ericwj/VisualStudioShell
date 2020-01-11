#Requires -Module VSSetup
using module VSSetup
# See C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\Tools\vsdevcmd\core\parse_cmd.bat
# The alias for each argument is the name defined in that file
<#
	.Synopsis
	Formats the arguments to pass to Enter-VsDevShell.

	.Description
	Accepts the arguments defined in Common7\Tools\vsdevcmd\core\parse_cmd.bat which is part of
	the batch script(s) that start(s) a Visual Studio Command Prompt.

	.Parameter Architecture
	The target processor architecture. This is the architecture for compiled binaries/libraries.

	Optional. Valid values are "x86", "amd64", "arm", "arm64". The default is "x86".

	.Parameter HostArchitecture
	The processor architecture of the compiler binaries.

	Optional. Valid values are "x86", "amd64".

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

	.Parameter RemainingArguments
	Receives all parameters not bound to one of the other, named arguments.

	These values will be passed unmodified to Enter-VsDevShell.
#>
function Format-VisualStudioShellArguments {
	[CmdLetBinding()]
	Param(
		[ValidateSet($null, "x86", "amd64", "arm", "arm64")]
		[Alias("arch")]
		[string]$Architecture = $null,

		[ValidateSet($null, "x86", "amd64")]
		[Alias("host_arch")]
		[string]$HostArchitecture = $null,

		[ValidateScript({ Confirm-WindowsSdkVersion -WindowsSdkVersion $_ -AllowNullOrEmpty })]
		[Alias("winsdk")]
		[string]$WindowsSdkVersion = $null,

		[ValidateSet($null, "Desktop", "UWP")]
		[Alias("app_platform")]
		[string]$AppPlatform,

		[Alias("no_ext")]
		[switch]$NoExtensions = [switch]::new($false),

		[Alias("no_logo")]
		[switch]$NoLogo = [switch]::new($false),

		[ValidateSet($null, "none", "auto")]
		[Alias("startdir")]
		[string]$StartDirectoryMode = $null,

		# [Alias("test")] can't be the same case-insensitively
		[switch]$Test = [switch]::new($false),

		[Parameter(ValueFromRemainingArguments = $true)]
		[object[]]$RemainingArguments = $null,

		[Microsoft.VisualStudio.Setup.Instance]$VisualStudio = $null
	)
	$Result = [System.Collections.Generic.List[string]]::new()
	function NotNullOrEmpty([string]$s) { -not [string]::IsNullOrEmpty($s) }
	if (NotNullOrEmpty $Architecture) {
		$Result.Add("/arch=$Architecture")
	}
	if (NotNullOrEmpty $HostArchitecture) {
		$Result.Add("/host_arch=$HostArchitecture")
	}
	if (NotNullOrEmpty $WindowsSdkVersion) {
		if (-not (Confirm-WindowsSdkVersion -WindowsSdkVersion $WindowsSdkVersion -VisualStudio $VisualStudio)) {
			Write-Warning -Message "The Windows SDK Version '$WindowsSdkVersion' might be invalid." `
				-Category [ErrorCategory]::InvalidArgument
		}
		$Result.Add("/winsdk=$WindowsSdkVersion")
	}
	if (NotNullOrEmpty $AppPlatform) {
		$Result.Add("/app_platform=$AppPlatform")
	}
	if ($NoExtensions.IsPresent) {
		$Result.Add("/no_ext")
	}
	if ($NoLogo.IsPresent) {
		$Result.Add("/no_logo")
	}
	if (NotNullOrEmpty $StartDirectoryMode) {
		$Result.Add("/startdir=$StartDirectoryMode")
	}
	if ($Test.IsPresent) {
		$Result.Add("/test")
	}
	if ($null -ne $RemainingArguments) {
		$WasSwitch = $false
		$IsSwitch = $false
		[string]$Last = $null
		function IsThisASwitch([string]$value) {
			$null -ne $value -and `
			$value.Length -gt 1 -and `
			($value.StartsWith("/") -or $value.StartsWith("-"))
		}
		foreach ($item in $RemainingArguments) {
			$str = $item.ToString()
			$IsSwitch = IsThisASwitch $str
			if ($WasSwitch) {
				if ($IsSwitch) {
					$value = $Last
				} else {
					$value = "$Last=$str"
				}
				$Result.Add($value)
			} elseif (-not $IsSwitch) {
				$Result.Add($str)
			}

			$WasSwitch = $IsSwitch
			$Last = $item
		}
	}
	if ($Result.Count -eq 0) {
		return $null
	} else {
		return ($Result -join " ")
	}
}
