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

    New-UDTypography -Text 'Job Monitor Modal' -Variant h4 -Style @{ marginBottom = '8px' }
    
    New-UDButton -Text "Show Output" -OnClick { 
        Show-UDJobOutputModal -Script Monitor.ps1 -TrustCertificate
    }    
    
    New-UDTypography -Text 'Action Group Variations' -Variant h4 -Style @{ marginBottom = '8px' }

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
}
