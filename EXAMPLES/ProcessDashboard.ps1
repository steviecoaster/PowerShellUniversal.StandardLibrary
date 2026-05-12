New-UDApp -Title 'Process Dashboard' -Content {

    $newPageHeaderSplat = @{
        Title       = 'Process Dashboard'
        Subtitle    = 'System Monitoring'
        Icon        = 'microchip'
        Breadcrumb = @(
            @{ Label = 'Home';       Url = '/home' }
            @{ Label = 'Monitoring'; Url = '/monitoring' }
            'Processes'
        )
        HelpText    = 'Metrics and table auto-refresh every 30 seconds. Use the Refresh button on the table to force an immediate update.'
        Actions     = {
            New-UDButton -Text 'Refresh All' -Icon (New-UDIcon -Icon 'rotate') -OnClick {
                Sync-UDElement -Id 'card-process-count'
                Sync-UDElement -Id 'card-cpu-usage'
                Sync-UDElement -Id 'card-memory-usage'
                Sync-UDElement -Id 'process-table'
            }
        }
        Metadata    = {
            New-UDChip -Label "Host: $env:COMPUTERNAME" -Icon (New-UDIcon -Icon 'server')
            New-UDChip -Label "User: $env:USERNAME"     -Icon (New-UDIcon -Icon 'user')
        }
        Style       = @{ padding = '16px'; marginBottom = '24px' }
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
}
