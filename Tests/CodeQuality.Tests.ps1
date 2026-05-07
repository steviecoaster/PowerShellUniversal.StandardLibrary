#Requires -Module Pester
<#
.SYNOPSIS
    Code quality test harness for the PowerShellUniversal.StandardLibrary public functions.

.DESCRIPTION
    Enforces coding standards across all non-empty .ps1 files in the Public\ directory,
    including comment-based help completeness, structural requirements, naming conventions,
    and common PowerShell code smells.

    Run with:
        Invoke-Pester -Path .\Tests\CodeQuality.Tests.ps1 -Output Detailed
#>

BeforeDiscovery {
    $moduleName = 'PowerShellUniversal.StandardLibrary'
    $moduleRoot = Join-Path -Path $PSScriptRoot -ChildPath "..\$moduleName"
    $publicPath = Join-Path -Path $moduleRoot   -ChildPath 'Public'

    # Discover non-empty public function files; empty files are stubs not yet ready for testing
    $FunctionTestCases = Get-ChildItem -Path $publicPath -Filter '*.ps1' -File |
        Where-Object { $_.Length -gt 0 } |
        ForEach-Object {
            @{
                FunctionName = $_.BaseName
                FilePath     = $_.FullName
            }
        }

    # Detect PSScriptAnalyzer once during discovery so every It -Skip can reference it
    $PSSAAvailable = $null -ne (Get-Module -Name PSScriptAnalyzer -ListAvailable -ErrorAction SilentlyContinue)
}

# ============================================================================
#  Module Manifest
# ============================================================================
Describe 'Module Manifest' {
    BeforeAll {
        $moduleName     = 'PowerShellUniversal.StandardLibrary'
        $manifestPath   = Join-Path -Path $PSScriptRoot -ChildPath "..\$moduleName\$moduleName.psd1"
        $publicPath     = Join-Path -Path $PSScriptRoot -ChildPath "..\$moduleName\Public"

        $script:Manifest      = Import-PowerShellDataFile -Path $manifestPath
        $script:DiskFunctions = Get-ChildItem -Path $publicPath -Filter '*.ps1' -File |
            Where-Object { $_.Length -gt 0 } |
            Select-Object -ExpandProperty BaseName
    }

    It 'FunctionsToExport should not use wildcards' {
        $script:Manifest.FunctionsToExport |
            Should -Not -Contain '*' -Because 'wildcards prevent PowerShell from optimising module loading'
    }

    It 'CmdletsToExport should not use wildcards' {
        $script:Manifest.CmdletsToExport | Should -Not -Contain '*'
    }

    It 'AliasesToExport should not use wildcards' {
        $script:Manifest.AliasesToExport | Should -Not -Contain '*'
    }

    It 'should have a non-empty Description' {
        $script:Manifest.Description | Should -Not -BeNullOrEmpty
    }

    It 'should have an Author defined' {
        $script:Manifest.Author | Should -Not -BeNullOrEmpty
    }

    It 'should have a GUID' {
        $script:Manifest.GUID |
            Should -Not -BeNullOrEmpty -Because 'a GUID uniquely identifies the module in the PowerShell Gallery'
    }

    It 'FunctionsToExport should include every non-empty file in Public\' {
        $script:DiskFunctions |
            Should -BeIn $script:Manifest.FunctionsToExport -Because 'every implemented public function must be listed in FunctionsToExport'
    }

    It 'FunctionsToExport should not reference functions with no matching file' {
        $script:Manifest.FunctionsToExport |
            Should -BeIn $script:DiskFunctions -Because 'FunctionsToExport must not list functions that have no implementation file'
    }
}

# ============================================================================
#  Per-Function Code Quality
# ============================================================================
Describe 'Public Function: <FunctionName>' -ForEach $FunctionTestCases {

    BeforeAll {
        $parseErrors       = $null
        $script:Tokens     = $null

        $script:Ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $FilePath,
            [ref]$script:Tokens,
            [ref]$parseErrors
        )

        $script:ParseErrors = $parseErrors

        $script:FunctionDef = $script:Ast.Find(
            { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] },
            $false
        )

        $script:HelpContent = $script:FunctionDef.GetHelpContent()
        $script:Parameters  = $script:FunctionDef.Body.ParamBlock.Parameters
    }

    # ------------------------------------------------------------------------
    Context 'Parse Validity' {

        It 'should contain valid PowerShell syntax with no parse errors' {
            $script:ParseErrors | Should -BeNullOrEmpty
        }

        It 'should define exactly one top-level function' {
            $allFunctions = $script:Ast.FindAll(
                { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] },
                $false
            )
            @($allFunctions).Count |
                Should -Be 1 -Because 'each file in Public\ should define exactly one exported function'
        }

        It 'the function name should match the file name' {
            $script:FunctionDef.Name |
                Should -Be $FunctionName -Because 'the function name must match the .ps1 file name for auto-loading to work'
        }
    }

    # ------------------------------------------------------------------------
    Context 'Comment-Based Help' {

        It 'should have a non-empty .SYNOPSIS' {
            $script:HelpContent.Synopsis |
                Should -Not -BeNullOrEmpty -Because 'Get-Help displays .SYNOPSIS in brief help output'
        }

        It 'should have a non-empty .DESCRIPTION' {
            $script:HelpContent.Description |
                Should -Not -BeNullOrEmpty -Because 'Get-Help -Full displays .DESCRIPTION; it must explain the function purpose'
        }

        It 'should contain at least one .EXAMPLE' {
            @($script:HelpContent.Examples).Count |
                Should -BeGreaterOrEqual 1 -Because 'examples are the first thing users look for in help'
        }

        It '.EXAMPLE blocks should not be empty' {
            foreach ($example in $script:HelpContent.Examples) {
                $example.Trim() |
                    Should -Not -BeNullOrEmpty -Because '.EXAMPLE sections must contain runnable code or a clear description'
            }
        }

        It 'every parameter should have a .PARAMETER entry' {
            $undocumented = $script:Parameters | Where-Object {
                $paramName   = $_.Name.VariablePath.UserPath
                $matchingKey = $script:HelpContent.Parameters.Keys |
                    Where-Object { $_ -ieq $paramName } |
                    Select-Object -First 1
                $null -eq $matchingKey
            } | ForEach-Object { $_.Name.VariablePath.UserPath }

            $undocumented |
                Should -BeNullOrEmpty -Because "all parameters need .PARAMETER help entries; undocumented: $($undocumented -join ', ')"
        }

        It '.PARAMETER descriptions should not be blank' {
            $emptyParams = $script:HelpContent.Parameters.GetEnumerator() |
                Where-Object { [string]::IsNullOrWhiteSpace($_.Value) } |
                ForEach-Object { $_.Key }

            $emptyParams |
                Should -BeNullOrEmpty -Because "parameter descriptions must not be blank; empty entries: $($emptyParams -join ', ')"
        }
    }

    # ------------------------------------------------------------------------
    Context 'Function Structure' {

        It 'should use [CmdletBinding()]' {
            $hasCmdletBinding = $script:FunctionDef.Body.ParamBlock.Attributes |
                Where-Object { $_.TypeName.Name -eq 'CmdletBinding' }

            $hasCmdletBinding |
                Should -Not -BeNullOrEmpty -Because '[CmdletBinding()] provides -Verbose, -ErrorAction, -WhatIf, and pipeline support'
        }

        It 'should use an approved PowerShell verb' {
            $verb          = ($FunctionName -split '-')[0]
            $approvedVerbs = (Get-Verb).Verb

            $verb |
                Should -BeIn $approvedVerbs -Because "unapproved verbs generate import warnings; run 'Get-Verb' for the full list"
        }

        It 'should follow Verb-Noun naming with PascalCase and a single hyphen' {
            $FunctionName |
                Should -Match '^[A-Z][a-zA-Z]+-[A-Z][a-zA-Z]+$' -Because 'PowerShell naming convention requires PascalCase Verb-Noun with one hyphen'
        }

        It 'every parameter should declare an explicit type constraint' {
            $untypedParams = $script:Parameters | Where-Object {
                $typeConstraints = $_.Attributes |
                    Where-Object { $_ -is [System.Management.Automation.Language.TypeConstraintAst] }
                @($typeConstraints).Count -eq 0
            } | ForEach-Object { $_.Name.VariablePath.UserPath }

            $untypedParams |
                Should -BeNullOrEmpty -Because "typed parameters prevent unexpected input and improve tab-completion; untyped: $($untypedParams -join ', ')"
        }

        It 'every parameter should be decorated with [Parameter()]' {
            $undecoratedParams = $script:Parameters | Where-Object {
                $paramAttrib = $_.Attributes |
                    Where-Object { $_.TypeName.Name -eq 'Parameter' }
                @($paramAttrib).Count -eq 0
            } | ForEach-Object { $_.Name.VariablePath.UserPath }

            $undecoratedParams |
                Should -BeNullOrEmpty -Because "explicit [Parameter()] clarifies intent and enables pipeline binding; missing on: $($undecoratedParams -join ', ')"
        }

        It 'state-changing verbs should declare SupportsShouldProcess' {
            $stateChangingVerbs = @(
                'Remove', 'Set', 'Clear', 'Reset', 'Update', 'Delete',
                'Stop', 'Suspend', 'Revoke', 'Block', 'Deny', 'Disable'
            )
            $verb = ($FunctionName -split '-')[0]

            if ($verb -notin $stateChangingVerbs) {
                Set-ItResult -Skipped -Because "verb '$verb' does not require SupportsShouldProcess"
                return
            }

            $cmdletBindingAttrib = $script:FunctionDef.Body.ParamBlock.Attributes |
                Where-Object { $_.TypeName.Name -eq 'CmdletBinding' }

            $hasShouldProcess = $cmdletBindingAttrib.NamedArguments |
                Where-Object {
                    $_.ArgumentName -eq 'SupportsShouldProcess' -and
                    $_.Argument.Extent.Text -ne '$false'
                }

            $hasShouldProcess |
                Should -Not -BeNullOrEmpty -Because "[CmdletBinding(SupportsShouldProcess)] is required for the '$verb' verb"
        }
    }

    # ------------------------------------------------------------------------
    Context 'Style and Code Smells' {

        It 'should not use backtick line continuations' {
            $backticks = $script:Tokens | Where-Object { $_.Kind -eq 'LineContinuation' }

            $backticks |
                Should -BeNullOrEmpty -Because 'backtick continuations hurt readability and break on trailing spaces; use splatting or natural line breaks'
        }

        It 'should not use Write-Host' {
            $writeHostCalls = $script:Ast.FindAll({
                $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                $args[0].GetCommandName() -eq 'Write-Host'
            }, $true)

            $writeHostCalls |
                Should -BeNullOrEmpty -Because 'Write-Host bypasses the pipeline and cannot be redirected; use Write-Output, Write-Verbose, or Write-Information'
        }

        It 'should not use Invoke-Expression' {
            $iexCalls = $script:Ast.FindAll({
                $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                $args[0].GetCommandName() -in @('Invoke-Expression', 'iex')
            }, $true)

            $iexCalls |
                Should -BeNullOrEmpty -Because 'Invoke-Expression is a security risk and makes code difficult to audit or test'
        }

        It 'should not use command aliases in place of full cmdlet names' {
            $allAliasNames  = (Get-Alias).Name
            $commandsInFile = $script:Ast.FindAll({
                $args[0] -is [System.Management.Automation.Language.CommandAst]
            }, $true) | ForEach-Object { $_.GetCommandName() } | Where-Object { $_ }

            $usedAliases = $commandsInFile | Where-Object { $_ -in $allAliasNames }

            $usedAliases |
                Should -BeNullOrEmpty -Because "aliases are environment-dependent and reduce readability; replace with full names: $($usedAliases -join ', ')"
        }

        It 'should not reference $global: scoped variables' {
            $globalVarRefs = $script:Ast.FindAll({
                $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $args[0].VariablePath.IsGlobal
            }, $true) | ForEach-Object { $_.Extent.Text }

            $globalVarRefs |
                Should -BeNullOrEmpty -Because "global variables create hidden coupling between functions; found: $($globalVarRefs -join ', ')"
        }

        It 'should not place $null on the right-hand side of -eq or -ne' {
            $nullOnRight = $script:Ast.FindAll({
                $node = $args[0]
                $node -is [System.Management.Automation.Language.BinaryExpressionAst] -and
                $node.Operator -in @('Ieq', 'Ine', 'Ceq', 'Cne') -and
                $node.Right -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $node.Right.VariablePath.UserPath -eq 'null'
            }, $true) | ForEach-Object { $_.Extent.Text }

            $because = 'put $null on the left ($null -eq $x) to avoid array-unrolling bugs with -eq; found: ' + ($nullOnRight -join ', ')
            $nullOnRight | Should -BeNullOrEmpty -Because $because
        }

        It 'should not suppress output with Out-Null (prefer [void] cast)' {
            $outNullCalls = $script:Ast.FindAll({
                $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                $args[0].GetCommandName() -eq 'Out-Null'
            }, $true)

            $outNullCalls |
                Should -BeNullOrEmpty -Because 'piping to Out-Null creates an unnecessary pipeline; use [void](expression) instead'
        }

        It 'should not use positional parameters when calling cmdlets' {
            # Walk each CommandAst's elements in order, tracking whether a bare value
            # follows a named parameter (its argument) or appears on its own (positional).
            # Splatted variables (@splat) are excluded — they are never positional.
            $positionalCalls = $script:Ast.FindAll({
                $node = $args[0]
                if ($node -isnot [System.Management.Automation.Language.CommandAst]) { return $false }
                $cmdName = $node.GetCommandName()
                # Only check Verb-Noun style commands
                if (-not ($cmdName -match '^[A-Za-z]+-[A-Za-z]+')) { return $false }

                $prevWasNamedParam = $false
                $isFirst = $true
                foreach ($el in $node.CommandElements) {
                    if ($isFirst) { $isFirst = $false; continue }  # skip the command name itself

                    if ($el -is [System.Management.Automation.Language.CommandParameterAst]) {
                        $prevWasNamedParam = $true
                        continue
                    }
                    if ($el -is [System.Management.Automation.Language.VariableExpressionAst] -and $el.Splatted) {
                        $prevWasNamedParam = $false
                        continue  # @splat is never a positional argument
                    }
                    if ($prevWasNamedParam) {
                        $prevWasNamedParam = $false
                        continue  # this element is the value argument for the preceding -Parameter
                    }
                    return $true  # bare value with no preceding -Parameter = positional
                }
                return $false
            }, $true) | ForEach-Object { $_.Extent.Text }

            $positionalCalls |
                Should -BeNullOrEmpty -Because 'positional parameters reduce readability and are fragile; always use named parameters'
        }
    }

    # ------------------------------------------------------------------------
    Context 'PSScriptAnalyzer' {

        It 'should pass PSScriptAnalyzer with no errors or warnings' -Skip:(-not $PSSAAvailable) {
            $excludedRules = @(
                # Covered by the dedicated SupportsShouldProcess test in this harness
                'PSUseShouldProcessForStateChangingFunctions',
                # False-positive when parameters are consumed inside ScriptBlock::Create() strings
                'PSReviewUnusedParameter',
                # BOM encoding is a repo-level editor setting, not a function code smell
                'PSUseBOMForUnicodeEncodedFile'
            )

            $analyzerParams = @{
                Path        = $FilePath
                Severity    = @('Error', 'Warning')
                ExcludeRule = $excludedRules
            }
            $results = Invoke-ScriptAnalyzer @analyzerParams
            $report  = ($results |
                Format-Table -Property RuleName, Severity, Message, Line -AutoSize |
                Out-String).Trim()

            $results | Should -BeNullOrEmpty -Because "PSScriptAnalyzer reported:`n$report"
        }
    }
}
