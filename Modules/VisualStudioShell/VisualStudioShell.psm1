
. "$PSScriptRoot\Confirm-VisualStudioInstance.ps1"
. "$PSScriptRoot\Confirm-WindowsSdkVersion.ps1"
. "$PSScriptRoot\Enter-VisualStudioShell.ps1"
. "$PSScriptRoot\Format-VisualStudioShellArguments.ps1"
. "$PSScriptRoot\Get-VisualStudio.ps1"
. "$PSScriptRoot\Import-VisualStudioShellModule.ps1"
. "$PSScriptRoot\Import-VisualStudioSetupModule.ps1"
. "$PSScriptRoot\Start-VisualStudio.ps1"

$script:IsSetupModuleLoaded = $false
$script:SetupModuleName = "VSSetup"
$script:SetupModuleMinVersion = "2.2.16"
$script:ShellModuleName = "Microsoft.VisualStudio.DevShell"
$script:ShellModuleMinVersion = "1.0.0" # Don't know what oldest version might work

function Get-VisualStudioShellInternalConfig {
	$result = [pscustomobject]@{
		HasValue              = $true
		IsSetupModuleLoaded   = $script:IsSetupModuleLoaded
		SetupModuleName       = $script:SetupModuleName
		SetupModuleMinVersion = $script:SetupModuleMinVersion
		ShellModuleName       = $script:ShellModuleName
		ShellModuleMinVersion = $script:ShellModuleMinVersion
	}
	return $result
}

New-Alias -Name vshell -Value Enter-VisualStudioShell
New-Alias -Name vs -Value Start-VisualStudio

Export-ModuleMember -Function Confirm-VisualStudioInstance
Export-ModuleMember -Function Confirm-WindowsSdkVersion
Export-ModuleMember -Function Enter-VisualStudioShell -Alias *
Export-ModuleMember -Function Format-VisualStudioShellArguments
Export-ModuleMember -Function Get-VisualStudio
Export-ModuleMember -Function Import-VisualStudioShellModule
Export-ModuleMember -Function Import-VisualStudioSetupModule
Export-ModuleMember -Function Start-VisualStudio -Alias *

if ($true) {
	Export-ModuleMember -Function Get-VisualStudioShellInternalConfig
}
