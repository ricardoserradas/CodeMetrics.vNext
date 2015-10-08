param (
	$planId,
	$suiteId,
	$configId,
	$testEnvironment,
	$settingsName,
	$buildDir
)

[bool]$validationErrors = $false

If (-not ($planId -as [int]))
{
	Write-Error "The Test Plan ID must be a number."
	$validationErrors = $true
}

If (-not ($suiteId -as [int]))
{
	Write-Error "The Test Suite ID must be a number."
	$validationErrors = $true
}

If (-not ($configId -as [int]))
{
	Write-Error "The Test Configuration ID must be a number."
	$validationErrors = $true
}

If($validationErrors)
{
	Exit
}

Write-Verbose 'Entering tcmrunner.ps1'

# For the TFS environment variables, I used this source:
# https://msdn.microsoft.com/en-us/library/hh850448.aspx

# Import the Task.Common dll that has all the cmdlets we need for Build
#import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

$vs14InstallPath = $env:VS140COMNTOOLS.Replace("\Tools", "\IDE")
$vs12InstallPath = $env:VS120COMNTOOLS.Replace("\Tools", "\IDE")
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
	Write-Error "You don't have TCM installed."
}

$tcmPath = Join-Path $vsInstallPath "TCM.exe"

Write-Output $tcmPath

&"whoami"

Write-Output "Starting Test Case Management Utility"

Write-Output "$tcmPath" run -create -collection:"$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)" -teamproject:"$($env:SYSTEM_TEAMPROJECT)" -planid:$planId -suiteid:$suiteId -testenvironment:$testEnvironment -settingsname:"""$settingsName""" -builddir:"$buildDir" -title:"$($env:BUILD_BUILDNUMBER)" -owner:"$($env:BUILD_QUEUEDBY)" -configid:"$configId" # -build:$($env:BUILD_BUILDNUMBER) -builddefinition:"$($env:BUILD_DEFINITIONNAME)"

			&"$tcmPath" run -create -collection:"$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)" -teamproject:"$($env:SYSTEM_TEAMPROJECT)" -planid:$planId -suiteid:$suiteId -testenvironment:$testEnvironment -settingsname:"""$settingsName""" -builddir:"$buildDir" -title:"$($env:BUILD_BUILDNUMBER)" -owner:"$($env:BUILD_QUEUEDBY)" -configid:"$configId" # -build:$($env:BUILD_BUILDNUMBER) -builddefinition:"$($env:BUILD_DEFINITIONNAME)"

Write-Output "Test Plan Execution finished successfully"

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