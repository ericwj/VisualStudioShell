#Requires -Module VSSetup
using module VSSetup
using namespace System.Management.Automation
<#
	.Synopsis
	Start a Developer Command Prompt for Visual Studio.

	.Description
	Load the Microsoft.VisualStudio.DevShell module for the Visual Studio Setup Instance
	specified and use it to start a Developer Command Prompt.

	.Parameter VisualStudio
	The Visual Studio Setup Instance.

	Use the VSSetup module or Get-VisualStudio CmdLet to obtain this instance.
#>
function Import-VisualStudioShellModule {
	[CmdLetBinding()]
	Param(
		[Parameter(Mandatory = $true)][ValidateNotNull()]
		[Microsoft.VisualStudio.Setup.Instance]$VisualStudio
	)
	function LogResult($Module) {
		if ($null -eq $Module) {
			Write-Verbose "Module '$ModuleName' was not loaded."
			return $false
		} else {
			Write-Verbose "Module '$ModuleName' [$($Module.Version)] was loaded from '$($Module.Path)'."
			return $true
		}
	}
	function ThrowIfModuleNotFound([string]$ModulePath) {
		throw [ErrorRecord]::new(
			[System.Exception]::new("Required assembly could not be located. This most likely indicates an installation error. Try repairing your Visual Studio installation. Expected location: $modulePath"),
			"DevShellModuleLoad",
			[ErrorCategory]::NotInstalled,
			$VisualStudio)
	}
	# Developer PowerShell for VS 2019 Preview
	# C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -noe -c "&{Import-Module """C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"""; Enter-VsDevShell f80816f7}"
	$ModuleName = $ShellModuleName
	$ModulePath = "$($VisualStudio.InstallationPath)\Common7\Tools\$ModuleName.dll"
	if (-not (Test-Path $ModulePath -PathType Leaf)) {
		Write-Verbose "Module not found in default location '$ModulePath'."
		# See C:\Program Files (x86)\Microsoft Visual Studio\2019\Preview\Common7\Tools\Launch-VsDevShell.ps1
		# Prior to 16.3 the DevShell module was in a different location
		$ModulePath = "$($VisualStudio.IntallationPath)\Common7\Tools\vsdevshell\$ModuleName.dll"
	}
	if (-not (Test-Path $ModulePath -PathType Leaf)) {
		Write-Verbose "Module not found in alternate location '$ModulePath'."
		ThrowIfModuleNotFound -ModulePath $ModulePath
	}
	$KnownFault = $false
	try {
		Import-Module $ModulePath
	} catch [System.IO.FileLoadException] {
		$KnownFault = $true
	}
	$Module = Get-Module Microsoft.VisualStudio.DevShell
	if ($null -eq $Module) {
		return LogResult($Module)
	}
	if ($KnownFault) {
		Write-Verbose "The module has already been imported from a different installation of Visual Studio:"
		$Module.Path | Write-Verbose
	}
	return LogResult($Module)
}
