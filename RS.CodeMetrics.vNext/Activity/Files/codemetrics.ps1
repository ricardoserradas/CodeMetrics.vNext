param (
	$analysisroot,
	$searchgac,
	$ignoregeneratedcode,
	$fileSearchPattern
)

[bool]$validationErrors = $false

If (-not ($searchgac -as [bool]))
{
	Write-Error "The Search GAC parameter must be True or False."
	$validationErrors = $true
}

If (-not ($ignoregeneratedcode -as [bool]))
{
	Write-Error "The Ignore Generated Code parameter must be True or False."
	$validationErrors = $true
}

If($validationErrors)
{
	Exit
}

Write-Verbose 'Entering codemetrics.ps1'

# For the TFS environment variables, I used this source:
# https://msdn.microsoft.com/en-us/library/hh850448.aspx

# Import the Task.Common dll that has all the cmdlets we need for Build
#import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

$vs14InstallPath = $env:VS140COMNTOOLS.Replace("\Common7\Tools", "\Team Tools\Static Analysis Tools\FxCop")
$vs12InstallPath = $env:VS120COMNTOOLS.Replace("\Common7\Tools", "\Team Tools\Static Analysis Tools\FxCop")
$vsInstallPath = ""

If (Test-Path $vs14InstallPath) {
	$vsInstallPath = $vs14InstallPath
	Write-Output $vsInstallPath
}
ElseIf (Test-Path $vs12InstallPath) {
	$vsInstallPath = $vs12InstallPath
	Write-Output $vsInstallPath
}
Else{
	Write-Error "You don't have Code Metrics Power Tools installed."
}

$codeMetricsPath = Join-Path $vsInstallPath "metrics.exe"

Write-Output $codeMetricsPath

Write-Output "Starting Code Metrics Power Tool"

&"$codeMetricsPath" -file:"$analysisroot\$fileSearchPattern" -out:"$($env:BUILD_STAGINGDIRECTORY)\metricsoutput.xml"

Write-Output "Code Metrics extraction finished successfully"

#$binaryLocation = join-path (Get-ItemProperty $registrykey[0]).InstallDir "bin\ReleaseManagementBuild.exe"

# Call Release Management Build
#$params = "release -tfs $($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI) -tp $($env:SYSTEM_TEAMPROJECT) -bd $($env:BUILD_DEFINITIONNAME) -bn $($env:BUILD_BUILDNUMBER)"
#if ($targetStage) {
#    &"$binaryLocation" release -tfs "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)" -tp "$($env:SYSTEM_TEAMPROJECT)" -bd "$($env:BUILD_DEFINITIONNAME)" -bn "$($env:BUILD_BUILDNUMBER)" -ts "$($targetStage)"    
#}
#else {
#    &"$binaryLocation" release -tfs "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)" -tp "$($env:SYSTEM_TEAMPROJECT)" -bd "$($env:BUILD_DEFINITIONNAME)" -bn "$($env:BUILD_BUILDNUMBER)"
#}

#if ($LastExitCode -ne 0) {
#    Write-Error "Release failed with an exit code of $LastExitCode"
#}