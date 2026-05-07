[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $Path = (Join-Path -Path $PSScriptRoot -ChildPath 'Tests')
)

$minimumPesterVersion = '5.0.0'

$pester = Get-Module -Name Pester -ListAvailable |
    Where-Object { $_.Version -ge [version]$minimumPesterVersion } |
    Sort-Object -Property Version -Descending |
    Select-Object -First 1

if ($null -eq $pester) {
    Write-Error "Pester $minimumPesterVersion or later is required. Install it with: Install-Module -Name Pester -MinimumVersion $minimumPesterVersion -Force"
    exit 1
}

Import-Module -Name $pester.Path -Force

$config = New-PesterConfiguration
$config.Run.Path = $Path
$config.Run.Exit = $true
$config.Output.Verbosity = 'Detailed'
$config.TestResult.Enabled = $true
$config.TestResult.OutputPath = Join-Path -Path $PSScriptRoot -ChildPath 'TestResults.xml'
$config.TestResult.OutputFormat = 'NUnitXml'

Invoke-Pester -Configuration $config
