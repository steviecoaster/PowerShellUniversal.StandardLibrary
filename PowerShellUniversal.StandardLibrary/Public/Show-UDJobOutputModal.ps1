function Show-UDJobOutputModal {
    <#
    .SYNOPSIS
        Invokes a PowerShell Universal script and streams its output into a live modal dialog.

    .DESCRIPTION
        Starts a PSU script job and immediately opens a full-width modal in the current dashboard
        page. The modal displays a terminal-style output pane that polls the job every two seconds
        and updates in real time until the job completes. Once the job finishes, a final status
        line is appended and the modal closes automatically after a short delay.

        The output pane uses a dark, monospace style by default to mimic a terminal, but every
        CSS property can be overridden through the Style parameter.

    .PARAMETER Script
        The name of the PSU script to invoke. Passed directly to Get-PSUScript -Name.

    .PARAMETER ScriptParameters
        An optional hashtable of parameters forwarded to the script when it is invoked via
        Invoke-PSUScript.

    .PARAMETER InitMessage
        The text shown in the output pane while the job is being queued and has not yet produced
        any output. Defaults to 'Waiting for job output'.

    .PARAMETER HeaderText
        The heading text displayed in the modal title bar. Defaults to 'Job Monitor'.

    .PARAMETER Style
        A hashtable of CSS styles applied to the pre element that renders the job output.
        Defaults to a dark terminal theme (black background, green monospace text, 500 px max height
        with a vertical scroll bar).

    .PARAMETER TrustCertificate
        When specified, passes -TrustCertificate to all underlying PSU cmdlets. Use this when the
        PSU server is using a self-signed or untrusted TLS certificate.

    .EXAMPLE
        Show-UDJobOutputModal -Script 'Deploy-Application.ps1'

        Runs the 'Deploy-Application.ps1' PSU script and streams its console output into a modal
        using the default terminal style and header text.

    .EXAMPLE
        Show-UDJobOutputModal -Script 'Invoke-Maintenance.ps1' `
            -ScriptParameters @{ Environment = 'Production'; DryRun = $false } `
            -HeaderText 'Maintenance Job' `
            -InitMessage 'Starting maintenance tasks'

        Passes parameters to the script and customises the modal header and initial message.

    .EXAMPLE
        $termStyle = @{
            'background-color' = '#0d1117'
            'color'            = '#c9d1d9'
            'font-family'      = 'Consolas, monospace'
            'font-size'        = '13px'
            'padding'          = '12px'
            'max-height'       = '600px'
            'overflow-y'       = 'auto'
            'white-space'      = 'pre-wrap'
            'width'            = '100%'
        }
        Show-UDJobOutputModal -Script 'Build-Report.ps1' -Style $termStyle -TrustCertificate

        Overrides the default output pane style with a GitHub-dark theme and trusts the PSU
        server certificate.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $Script,

        [Parameter()]
        [Hashtable]
        $ScriptParameters,

        [Parameter()]
        [String]
        $InitMessage = 'Waiting for job output',

        [Parameter()]
        [String]
        $HeaderText = 'Job Monitor',

        [Parameter()]
        [Hashtable]
        $Style = @{
            'background-color' = '#1e1e1e'
            'color'            = '#00ff00'
            'border-radius'    = '4px'
            'padding'          = '16px'
            'max-height'       = '500px'
            'overflow-y'       = 'auto'
            'font-family'      = 'Consolas, Monaco, monospace'
            'font-size'        = '12px'
            'white-space'      = 'pre-wrap'
            'min-height'       = '300px'
            'width'            = '100%'
        },

        [Parameter()]
        [Switch]
        $TrustCertificate
    )

    end {

        $getPSUScriptSplat = @{
            Name = $Script
            TrustCertificate = $TrustCertificate.IsPresent
        }

        $psuscript = Get-PSUScript @getPSUScriptSplat
                                            
        # Start the job and monitor it in a modal
        $invokePSUScriptSplat = @{
            Script           = $psuscript
            TrustCertificate = $TrustCertificate.IsPresent
        }

        if ($ScriptParameters) {
            $invokePSUScriptSplat.Add('Parameters', $ScriptParameters)
        }

        $Job = Invoke-PSUScript @invokePSUScriptSplat

        # Show modal with job monitoring
        Show-UDModal -Content {
            New-UDElement -Id 'ModalJobOutput' -Tag 'pre' -Attributes @{
                style = $Style
            } -Content {
                "$InitMessage...`r`n"
            }
        } -Header {
            New-UDTypography -Text $HeaderText -Variant h5
        } -FullWidth -MaxWidth 'lg' -Persistent
                                            
        # Monitor job in background
        while ($Job.Status -eq 'Running' -or $Job.Status -eq 'Queued') {
            try {
                $getPSUJobOutputSplat = @{
                    Job              = $Job
                    TrustCertificate = $TrustCertificate.IsPresent
                    ErrorAction      = 'SilentlyContinue'
                }

                [array]$Output = Get-PSUJobOutput @getPSUJobOutputSplat
                                                    
                Set-UDElement -Id 'ModalJobOutput' -Content {
                    if ($Output -and $Output.Length -gt 0) {
                        ($Output | ForEach-Object -Process { "$_`r`n" }) -join ""
                    }
                    else {
                        "Waiting for job output..."
                    }
                }
            }
            catch {
                Write-Verbose -Message "Error getting job output: $($_.Exception.Message)"
            }
                                                
            $getPSUJobSplat = @{
                Id               = $Job.Id
                TrustCertificate = $TrustCertificate.IsPresent
                ErrorAction      = 'SilentlyContinue'
            }

            $Job = Get-PSUJob @getPSUJobSplat
            Start-Sleep -Seconds 2
        }
                                            
        # Get final output and close modal
        try {
            $getPSUJobOutputSplat = @{
                Job              = $Job
                TrustCertificate = $TrustCertificate.IsPresent
                ErrorAction      = 'SilentlyContinue'
            }

            [array]$FinalOutput = Get-PSUJobOutput @getPSUJobOutputSplat
            Set-UDElement -Id 'ModalJobOutput' -Content {
                if ($FinalOutput -and $FinalOutput.Length -gt 0) {
                    $finalText = ($FinalOutput | ForEach-Object -Process { "$_`r`n" }) -join ""
                    "$finalText`r`n`r`n--- Job $($Job.Status) ---"
                }
                else {
                    "Job completed but no output was captured.`r`n`r`n--- Job $($Job.Status) ---"
                }
            }
        }
        catch {
            Set-UDElement -Id 'ModalJobOutput' -Content {
                "Error retrieving final job output: $($_.Exception.Message)`r`n`r`n--- Job $($Job.Status) ---"
            }
        }
                                            
        Start-Sleep -Seconds 3
        Hide-UDModal
    }
}