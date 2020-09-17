#Requires -Module VSSetup
using module VSSetup
<#
	.Synopsis
	Starts Common7\IDE\devenv.exe in the installation path for the Visual Studio setup instance
	provided explicitly, or if none was provided, the one selected running Get-VisualStudio.

	.Parameter FileOrFolder
	The file or folder path to pass as the first argument to devenv.exe. The default is none.

	.Parameter StartInPath
	The working directory for devenv.exe. Defaults to the current working directory.

	.Parameter ExcludePrerelease
	Do not allow selection of Preview versions of Visual Studio. (Passed through negated to Get-VSSetupInstance)

	.Parameter VisualStudio
	A setup instance obtained from the VSSetup PowerShell module.

	.Parameter RemainingArguments
	Any arguments that will be provided unmodified to devenv.exe.
#>
function Start-VisualStudio {
	[CmdLetBinding(
		SupportsShouldProcess = $true,
		ConfirmImpact = [System.Management.Automation.ConfirmImpact]::Medium
	)]
	Param(
		[Parameter(Position = 1)]
		[string]$FileOrFolder = $null,

		[string]$StartInPath = $PWD,

		[switch]$Force = [switch]::new($false),

		[Parameter(ParameterSetName='select')]
		[switch]$ExcludePrerelease = [switch]::new($false),

		[Parameter(ParameterSetName='instance')]
		[Microsoft.VisualStudio.Setup.Instance]$VisualStudio = $null,

		[Parameter(ValueFromRemainingArguments = $true)]
		[object[]]$RemainingArguments = $null
	)
	Process {
		switch ($PSCmdLet.ParameterSetName) {
			'instance' {
				if (-not (Confirm-VisualStudio $VisualStudio)) {
					Write-Error "The Visual Studio parameter is not valid. Remove the parameter or specify a valid value."
					return;
				}
			}
			default {
				$VisualStudio = Get-VisualStudio -ExcludePrerelease:($ExcludePrerelease.IsPresent) -Product:$Product
			}
		}
		if (-not (Import-VisualStudioShellModule -VisualStudio $VisualStudio)) {
			Write-Error "Could not load the Visual Studio Shell module."
		}

		$FilePath = "$($VisualStudio.InstallationPath)\Common7\IDE\devenv.exe"
		$ArgumentList = @($FileOrFolder) + $RemainingArguments

		$target = "{0} [{1}]" -f @(
			$VisualStudio.DisplayName
			$VisualStudio.InstallationName
			$VisualStudio.InstallationPath
		)
		$action = "devenv -Arguments '{1}'" -f @(
			$FilePath
			$($ArgumentList -join " ")
			$StartInPath
		)
		$PSCmdlet.ShouldProcess($target, $action)
		Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -WorkingDirectory $StartInPath
	}
}
