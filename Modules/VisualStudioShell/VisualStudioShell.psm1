#Requires -Version 5.0
#Requires -Module @{ ModuleName = 'VSSetup'; ModuleVersion = '2.0.0' }

using module VSSetup

. "$PSScriptRoot\Confirm-WindowsSdkVersion.ps1"
. "$PSScriptRoot\Enter-VisualStudioShell.ps1"
. "$PSScriptRoot\Format-VisualStudioShellArguments.ps1"
. "$PSScriptRoot\Get-VisualStudio.ps1"
. "$PSScriptRoot\Import-VisualStudioShellModule.ps1"
. "$PSScriptRoot\Start-VisualStudio.ps1"

$script:ShellModuleName = "Microsoft.VisualStudio.DevShell"
$script:ShellModuleMinVersion = "1.0.0" # Don't know what oldest version might work

New-Alias -Name vshell -Value Enter-VisualStudioShell
New-Alias -Name vs -Value Start-VisualStudio

Export-ModuleMember -Function Confirm-WindowsSdkVersion
Export-ModuleMember -Function Enter-VisualStudioShell -Alias *
Export-ModuleMember -Function Format-VisualStudioShellArguments
Export-ModuleMember -Function Get-VisualStudio
Export-ModuleMember -Function Import-VisualStudioShellModule
Export-ModuleMember -Function Start-VisualStudio -Alias *
