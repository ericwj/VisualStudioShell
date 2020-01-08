function Confirm-VisualStudioInstance {
	[CmdLetBinding()]
	Param([object]$vs)
	Process {
		function LogResult([bool]$result) {
			Write-Verbose ("$result == Confirm-VisualStudioInstance '{0}' [{1}], Packages={2}, InstallationPath='{3}'" -f @(
				$vs.DisplayName
				$vs.InstallationName,
				$vs.Packages.Count,
				$vs.InstallationPath))
			$result
		}
		return LogResult(
			$null -ne $vs -and `
			$null -ne $vs.DisplayName -and `
			$null -ne $vs.InstallationName -and `
			$null -ne $vs.InstallationPath -and `
			$null -ne $vs.Packages -and `
			$VS.Packages -is [System.Collections.IList] -and `
			$VS.Packages.Count -gt 0 -and `
			$null -ne $VS.Packages[0].Id
		)
	}
}