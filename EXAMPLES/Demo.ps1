New-UDApp -Title 'Standard Library Demo' -Content {

    $newPageHeaderSplat = @{
        Title      = 'Standard Library Dashboard'
        Subtitle   = 'This section is part of New-UDPageHeader'
        Icon       = 'microchip'
        Breadcrumb = @(
            @{ Label = 'Home'; Url = '/home' }
            @{ Label = 'Monitoring'; Url = '/monitoring' }
            'Processes'
        )
        HelpText   = 'Metrics and table auto-refresh every 30 seconds. Use the Refresh button on the table to force an immediate update.'
        Actions    = {
            New-UDButton -Text 'Refresh All' -Icon (New-UDIcon -Icon 'rotate') -OnClick {
                Sync-UDElement -Id 'card-process-count'
                Sync-UDElement -Id 'card-cpu-usage'
                Sync-UDElement -Id 'card-memory-usage'
                Sync-UDElement -Id 'process-table'
            }
        }
        Metadata   = {
            New-UDChip -Label "Host: $env:COMPUTERNAME" -Icon (New-UDIcon -Icon 'server')
            New-UDChip -Label "User: $env:USERNAME"     -Icon (New-UDIcon -Icon 'user')
        }
        Style      = @{ padding = '16px'; marginBottom = '24px' }
    }

    New-UDPageHeader @newPageHeaderSplat

    New-UDTypography -Text 'New-UDDataCard' -Variant 'h5' -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Renders a metric or status card built around a -Value script block. The value runs inside New-UDDynamic so it re-executes on every refresh without re-rendering the surrounding card. Set -RefreshInterval for automatic polling, or call Sync-UDElement against the card -Id to refresh on demand. Value color and all card-level styles are fully overridable.' -Style @{ marginBottom = '16px' }

    New-UDStack -Direction row -Spacing 2 -Content {

        $processCountSplat = @{
            Id              = 'card-process-count'
            Title           = 'Running Processes'
            Value           = { (Get-Process).Count }
            RefreshInterval = 30
            Style           = @{ borderLeft = '4px solid #1976d2'; borderRadius = '8px'; flex = '1' }
        }

        $cpuUsageSplat = @{
            Id              = 'card-cpu-usage'
            Title           = 'Top CPU Process'
            Value           = {
                $top = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 1
                '{0} ({1:N1}s)' -f $top.Name, $top.CPU
            }
            RefreshInterval = 30
            ValueColor      = '#e65100'
            Style           = @{ borderLeft = '4px solid #e65100'; borderRadius = '8px'; flex = '1' }
        }

        $memoryUsageSplat = @{
            Id              = 'card-memory-usage'
            Title           = 'Top Memory Process'
            Value           = {
                $top = Get-Process | Sort-Object -Property WorkingSet -Descending | Select-Object -First 1
                '{0} ({1:N0} MB)' -f $top.Name, ($top.WorkingSet / 1MB)
            }
            RefreshInterval = 30
            ValueColor      = '#2e7d32'
            Style           = @{ borderLeft = '4px solid #2e7d32'; borderRadius = '8px'; flex = '1' }
        }

        New-UDDataCard @processCountSplat
        New-UDDataCard @cpuUsageSplat
        New-UDDataCard @memoryUsageSplat
    }

    New-UDTypography -Text 'New-UDDynamicTable' -Variant 'h5' -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Combines New-UDDynamic and New-UDTable into a single call. Pass a -Data script block and a -Columns script block — both re-execute on every refresh cycle. Built-in search, sorting, pagination, and configurable page size are always enabled. Set -RefreshInterval for automatic polling, or omit it and a Refresh button is rendered automatically.' -Style @{ marginBottom = '16px' }

    $processTableSplat = @{
        Id              = 'process-table'
        RefreshInterval = 30
        Data            = {
            Get-Process |
            Sort-Object -Property CPU -Descending |
            Select-Object -First 50 Name, Id, CPU, WorkingSet, Handles
        }
        Columns         = {
            New-UDTableColumn -Property Name        -Title 'Name'        -ShowSort
            New-UDTableColumn -Property Id          -Title 'PID'         -ShowSort
            New-UDTableColumn -Property CPU         -Title 'CPU (s)'     -ShowSort -Render {
                '{0:N2}' -f [double]$EventData.CPU
            }
            New-UDTableColumn -Property WorkingSet  -Title 'Memory (MB)' -ShowSort -Render {
                '{0:N0}' -f ($EventData.WorkingSet / 1MB)
            }
            New-UDTableColumn -Property Handles     -Title 'Handles'     -ShowSort
        }
    }

    New-UDDynamicTable @processTableSplat

    New-UDTypography -Text 'Show-UDJobOutputModal' -Variant 'h5' -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Kicks off a PSU script job and opens a full-width modal that polls the job every two seconds, streaming its output into a terminal-style pane in real time. Once the job finishes, a status line is appended and the modal closes automatically. Pass -ScriptParameters to forward arguments, and use -Style to override the output pane appearance.' -Style @{ marginBottom = '16px' }
    
    New-UDButton -Text "Show Output" -OnClick { 
        Show-UDJobOutputModal -Script Monitor.ps1 -TrustCertificate
    }    
    
    New-UDTypography -Text 'New-UDActionGroup' -Variant 'h5' -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Wraps a set of buttons in a flex stack with consistent spacing. Direction (row, column, row-reverse, column-reverse) and gap are both configurable, and the container shrinks to fit its content by default. Assign an -Id and call Sync-UDElement to swap out button contents dynamically at runtime.' -Style @{ marginBottom = '16px' }

    # Direction selector applies to all groups
    New-UDSelect -Id 'dirSelect' -Label 'Direction' -Option {
        New-UDSelectOption -Name 'row' -Value 'row'
        New-UDSelectOption -Name 'column' -Value 'column'
        New-UDSelectOption -Name 'row-reverse' -Value 'row-reverse'
        New-UDSelectOption -Name 'column-reverse' -Value 'column-reverse'
    } -OnChange { Sync-UDElement -Id 'dynGroups' } -DefaultValue 'row'

    New-UDDynamic -Id 'dynGroups' -Content {
        $dirElement = Get-UDElement -Id 'dirSelect'
        $direction = if ($dirElement.value) { $dirElement.value } else { 'row' }

        # --- Standard filled buttons ---
        New-UDTypography -Text 'Standard' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px'; background = '#f5f5f5'; borderRadius = '8px' } -Button @(
            New-UDButton -Text 'Primary'  -Variant contained -Color primary   -OnClick { Show-UDToast -Message 'Primary clicked'  -MessageColor '#1976d2' }
            New-UDButton -Text 'Secondary' -Variant contained -Color secondary -OnClick { Show-UDToast -Message 'Secondary clicked' -MessageColor '#9c27b0' }
            New-UDButton -Text 'Error'    -Variant contained -Color error      -OnClick { Show-UDToast -Message 'Error clicked'    -MessageColor red }
        )

        # --- Outlined buttons ---
        New-UDTypography -Text 'Outlined' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px'; background = '#ffffff'; borderRadius = '8px'; border = '1px solid #e0e0e0' } -Button @(
            New-UDButton -Text 'Save'    -Variant outlined -Color primary   -Icon (New-UDIcon -Icon save)    -OnClick { Show-UDToast -Message 'Saved!'    -MessageColor green }
            New-UDButton -Text 'Edit'    -Variant outlined -Color default   -Icon (New-UDIcon -Icon edit)    -OnClick { Show-UDToast -Message 'Editing...' -MessageColor '#555' }
            New-UDButton -Text 'Delete'  -Variant outlined -Color error     -Icon (New-UDIcon -Icon trash)   -OnClick { Show-UDToast -Message 'Deleted!'   -MessageColor red }
        )

        # --- Text / ghost buttons ---
        New-UDTypography -Text 'Text (Ghost)' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px' } -Button @(
            New-UDButton -Text 'Accept' -Variant text -Color primary   -OnClick { Show-UDToast -Message 'Accepted' -MessageColor green }
            New-UDButton -Text 'Ignore' -Variant text -Color default   -OnClick { Show-UDToast -Message 'Ignored'  -MessageColor '#555' }
            New-UDButton -Text 'Reject' -Variant text -Color error     -OnClick { Show-UDToast -Message 'Rejected' -MessageColor red }
        )

        # --- Custom styled buttons ---
        New-UDTypography -Text 'Custom Styled' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px'; background = '#1e1e2e'; borderRadius = '8px' } -Button @(
            New-UDButton -Text 'Deploy'   -Style @{ background = '#4caf50'; color = '#fff'; fontWeight = '700' } -OnClick { Show-UDToast -Message 'Deploying...' -MessageColor '#4caf50' }
            New-UDButton -Text 'Rollback' -Style @{ background = '#ff9800'; color = '#fff'; fontWeight = '700' } -OnClick { Show-UDToast -Message 'Rolling back' -MessageColor '#ff9800' }
            New-UDButton -Text 'Destroy'  -Style @{ background = '#f44336'; color = '#fff'; fontWeight = '700' } -OnClick { Show-UDToast -Message '💀 Destroyed' -MessageColor red }
        )
    }

    New-UDTypography -Text 'New-UDFormTemplate' -Variant 'h5' -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Renders a fully-wired New-UDForm from a named template with pre-built fields and field-level validation in a single call. Nine templates cover common scenarios: Email, Feedback, SimpleRegistration, PasswordReset, ServiceRequest, ChangeRequest, UserOnboarding, Shipping, and Confirmation. Supply -OnSubmit, optionally -OnCancel, and everything else is handled for you. Field IDs in $EventData are stable and documented.' -Style @{ marginBottom = '16px' }

    New-UDStack -Direction row -Spacing 3 -Content {
        New-UDCard -Title 'Email / Newsletter' -Style @{ borderRadius = '6px'; border = '1px solid #e0e0e0'; boxShadow = 'none' } -Content {
            $p = @{
                Template      = 'Email'
                SubmitText    = 'Subscribe'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Subscribed: $($EventData.txtEmail)" }
            }
            New-UDFormTemplate @p
        }
        New-UDCard -Title 'Feedback' -Style @{ borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #1976d2' } -Content {
            $p = @{
                Template      = 'Feedback'
                SubmitText    = 'Send Feedback'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Feedback received: $($EventData.selCategory)" }
            }
            New-UDFormTemplate @p
        }
    }

    New-UDElement -Tag 'div' -Attributes @{ style = @{ width = '50%'; marginTop = '24px' } } -Content {
        New-UDCard -Title 'Change Request' -Style @{ borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #f57c00' } -Content {
            $p = @{
                Template      = 'ChangeRequest'
                SubmitText    = 'Raise Change'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Change request raised: $($EventData.txtTitle)" }
            }
            New-UDFormTemplate @p
        }
    }
}
