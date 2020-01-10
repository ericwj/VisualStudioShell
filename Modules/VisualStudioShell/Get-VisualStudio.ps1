#Requires -Module VSSetup
using module VSSetup
<#
	.Synopsis
	Obtain the latest installed version of Visual Studio.

	.Parameter ExcludePrerelease
	Do not allow selection of Preview versions of Visual Studio. (Passed through negated to Get-VSSetupInstance)
#>
function Get-VisualStudio {
	[CmdLetBinding()]
	[OutputType([Microsoft.VisualStudio.Setup.Instance])]
	Param(
		[switch]$ExcludePrerelease = [switch]::new($false)
	)
	$VS =
		Get-VSSetupInstance -Prerelease:$(-not $Prerelease.IsPresent) |
		Select-VSSetupInstance -Latest |
		Sort-Object -Property InstallationVersion |
		Select-Object -Last 1

	if ($null -eq $VS) {
		Write-Warning "Could not find an installed version of Visual Studio"
		return $null;
	}

	# Found
	$VSDisplayString = "{0} [{1}] in ""{2}""" -f @($VS.DisplayName, $VS.InstallationName, $VS.InstallationPath)
	Write-Verbose "Found $VSDisplayString"

	return $VS
}
