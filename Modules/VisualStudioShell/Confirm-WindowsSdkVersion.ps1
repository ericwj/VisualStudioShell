#Requires -Module VSSetup
using module VSSetup
<#
	.Synopsis
	Validates a Windows SDK version.

	.Description
	Validates that a Windows SDK version is valid and,
	if verified against an installed version of Visual Studio,
	that Visual Studio has the Windows SDK version installed.

	.Parameter WindowsSdkVersion
	The version string to validate.

	.Parameter VisualStudio
	The instance of Visual Studio to verify the Windows SDK version against.

	.Parameter AllowNullOrEmpty
	Indicates whether to accept a null value or the empty string as valid.
#>
function Confirm-WindowsSdkVersion {
	[CmdLetBinding()]
	Param(
		[string]$WindowsSdkVersion,
		[Microsoft.VisualStudio.Setup.Instance]$VisualStudio = $null,
		[switch]$AllowNullOrEmpty = [switch]::new($false)
	)
	Process {
		function LogResult([bool]$result) {
			Write-Verbose ("$result == Confirm-WindowsSdkVersion '{0}' NullOrEmpty={1}, RequireInstalled={2}, AllowNullOrEmpty={3}" -f @(
				$WindowsSdkVersion,
				([string]::IsNullOrEmpty($WindowsSdkVersion)),
				($null -ne $VisualStudio),
				($AllowNullOrEmpty.IsPresent)))
			$result
		}
		if ([string]::IsNullOrEmpty($WindowsSdkVersion) -and $AllowNullOrEmpty.IsPresent) {
			return LogResult($true)
		} elseif ($null -eq $VisualStudio) {
			# e.g. none, 8.1, 10.0.10240.0, 10.0.010240.0
			$rex = [System.Text.RegularExpressions.Regex]::new("(none|8.1|10.0.\d{5,6}.0)")
			return LogResult($rex.IsMatch($WindowsSdkVersion))
		} else {
			$esc = [System.Text.RegularExpressions.Regex]::Escape("Microsoft.VisualStudio.Component.Windows10SDK.")
			$rex = [System.Text.RegularExpressions.Regex]::new("$esc(?<v>\d{5,6})")
			$oke = @("none", "8.1") + (
				$VisualStudio.Packages |
				Where-Object { $rex.IsMatch($_.Id) } |
				ForEach-Object {
					$v = $rex.Match($_.Id).Groups["v"].Value
					return "10.0.$v.0"
				}
			)
			$result = $oke -contains $WindowsSdkVersion
			if (-not $result) {
				$valid = ($oke | ForEach-Object { """$_""" }) -join ", "
				Write-Warning "Windows SDK Version '$WindowsSdkVersion' is not valid or not installed. Valid values are: $valid"
			}
			return LogResult($result)
		}
	}
}
