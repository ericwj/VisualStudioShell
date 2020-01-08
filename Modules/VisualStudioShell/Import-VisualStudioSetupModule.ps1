<#
	.Synopsis
	Acquire and load the VSSetup module.

	.Description
	Acquire and load the VSSetup module, downloading it if necessary.

	.Parameter Force
	Never ask for confirmation interactively. Combining -WhatIf and -Force will still do nothing.
#>
function Import-VisualStudioSetupModule {
	[CmdLetBinding(
		SupportsShouldProcess = $true,
		ConfirmImpact = [System.Management.Automation.ConfirmImpact]::Medium
	)]
	Param(
		[switch]$Force = [switch]::new($false)
	)
	$ModuleName = $script:SetupModuleName
	$MinVersion = $script:SetupModuleMinVersion
	function LogResult([object]$Module) {
		if ($null -eq $Module) {
			Write-Verbose "Module '$ModuleName' was not loaded."
			return $false
		} else {
			Write-Verbose "Module '$ModuleName' [$($Module.Version)] was loaded from '$($Module.Path)'."
			return $true
		}
	}

	$Module = Get-Module -Name $ModuleName -All
	if ($null -eq $Module) {
		$Module = Get-Module -ListAvailable -Name $ModuleName -All
	}
	if ($null -eq $Module) {
		$action = "Install Module $ModuleName"
		$reason = [System.Management.Automation.ShouldProcessReason]::None
		if ($PSCmdlet.ShouldProcess($action, "$action?", $action, [ref]$reason) -and (
			$Force.IsPresent -or $PSCmdlet.ShouldContinue("$action?", $action)))
		{
			Install-Package -Name $ModuleName -MinimumVersion $MinVersion `
				-Force:$($Force.IsPresent) -Confirm:$false
			$Module = Get-Module -ListAvailable -Name $ModuleName
		}
	}
	if ($null -eq $Module) {
		Write-Error "Could not find or obtain PowerShell module ""$ModuleName""."
		$script:IsSetupModuleLoaded = $false
		return LogResult($Module)
	} else {
		Write-Verbose "Setting IsSetupModuleLoaded=True"
		$script:IsSetupModuleLoaded = $true
		return LogResult($Module)
	}
}
