function Start-VisualStudio {
	[CmdLetBinding(
		SupportsShouldProcess = $true,
		ConfirmImpact = [System.Management.Automation.ConfirmImpact]::Medium
	)]
	Param(
		[Parameter(Position = 1, Mandatory = $false)]
		[string]$FileOrFolder = $null,

		[string]$StartInPath = $PWD,

		[switch]$Force = [switch]::new($false),

		[switch]$ExcludePrerelease = [switch]::new($false),

		[ValidateScript({ Confirm-VisualStudioInstance $_ })]
		[object]$VisualStudio = $null,

		[Parameter(ValueFromRemainingArguments)]
		[object[]]$RemainingArguments = $null
	)
	Process {
		if ($null -eq $VisualStudio) {
			if (-not $script:IsSetupModuleLoaded) {
				$ok = Import-VisualStudioSetupModule `
					-Force:($Force.IsPresent) -ErrorAction Stop
				if (-not $ok) {
					Write-Error "The Visual Studio Setup module '$SetupModuleName' could not be loaded."
					return
				}
			}
			$VisualStudio = Get-VisualStudio -ExcludePrerelease:($ExcludePrerelease.IsPresent)
		} elseif (-not (Confirm-VisualStudio $VisualStudio)) {
			Write-Error "The Visual Studio parameter is not valid. Remove the parameter or specify a valid value."
			return;
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
