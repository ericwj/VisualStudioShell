[CmdLetBinding()]
Param()

$Name = "VisualStudioShell"
$Secrets = Get-Content "$env:AppData\Microsoft\UserSecrets\PowerShellGallery\secrets.json" | ConvertFrom-Json
if (-not [string]::IsNullOrEmpty($Secrets[$Name])) {
	$Key = @{
		Value = $Secrets[$Name]
		Name = $Name
		Source = "UserSecrets"
	}
} elseif (-not [string]::IsNullOrEmpty($Secrets.Default)) {
	$Key = @{
		Value = $Secrets.Default
		Name = "Default"
		Source = "UserSecrets"
	}
} else {
	throw [System.Collections.Generic.KeyNotFoundException]::new("An API key for the PowerShell Gallery could not be obtained.")
}
Write-Verbose "Using $($Key.Source) key '$($Key.Name)'."
$Path = "$PSScriptRoot\Modules\$Name"
Publish-Module -Path $Path -NuGetApiKey $Key.Value
