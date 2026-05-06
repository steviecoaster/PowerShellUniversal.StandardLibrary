function New-DynamicTable {
    <#
    .SYNOPSIS
        Creates a dynamic table component for use in PowerShell Universal dashboards.

    .DESCRIPTION
        Wraps New-UDDynamic and New-UDTable to reduce boilerplate when displaying tabular data
        in a PowerShell Universal app. The Data and Columns scriptblocks are embedded into the
        dynamic endpoint at call time, so each refresh re-executes both blocks to retrieve
        current data and rebuild columns.

        When RefreshInterval is not specified, a Refresh button is rendered below the table
        that triggers a manual sync of the dynamic region. When RefreshInterval is specified,
        the region auto-refreshes on that interval and no button is rendered.

    .PARAMETER Id
        The unique ID for the dynamic region. Also used as the target for Sync-UDElement.

    .PARAMETER Data
        A scriptblock that returns the data to display in the table. Executed inside the
        dynamic endpoint on every refresh.

    .PARAMETER Columns
        A scriptblock that returns an array of New-UDTableColumn objects defining the table
        columns. Executed inside the dynamic endpoint on every refresh.

    .PARAMETER PageSize
        The number of rows to display per page. Defaults to 15.

    .PARAMETER RefreshInterval
        The number of seconds between automatic refreshes. When omitted, a manual Refresh
        button is rendered instead.

    .EXAMPLE
        New-DynamicTable -Id 'process-table' -RefreshInterval 10 -Data {
            Get-Process | Select-Object -First 50 Name, Id, CPU, WorkingSet
        } -Columns {
            New-UDTableColumn -Property Name       -Title 'Name'        -ShowSort
            New-UDTableColumn -Property Id         -Title 'PID'         -ShowSort
            New-UDTableColumn -Property CPU        -Title 'CPU (s)'     -ShowSort -Render {
                '{0:N2}' -f [double]$EventData.CPU
            }
            New-UDTableColumn -Property WorkingSet -Title 'Memory (MB)' -ShowSort -Render {
                '{0:N0}' -f ($EventData.WorkingSet / 1MB)
            }
        }

        Displays the top 50 processes in a table that auto-refreshes every 10 seconds.

    .EXAMPLE
        New-DynamicTable -Id 'service-table' -Data {
            Get-Service | Select-Object Name, Status, StartType
        } -Columns {
            New-UDTableColumn -Property Name      -Title 'Name'       -ShowSort
            New-UDTableColumn -Property Status    -Title 'Status'     -ShowSort
            New-UDTableColumn -Property StartType -Title 'Start Type' -ShowSort
        }

        Displays services with a manual Refresh button, using the default page size of 15.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]
        $Id,

        [Parameter(Mandatory)]
        [ScriptBlock]
        $Data,

        [Parameter(Mandatory)]
        [ScriptBlock]
        $Columns,

        [Parameter()]
        [Int32]
        $PageSize = 15,

        [Parameter()]
        [Int32]
        $RefreshInterval
    )
    
    end {
        $sb = [System.Text.StringBuilder]::new()
        [void]$sb.AppendLine('$tableData = @(& {' + $Data.ToString() + '})')
        [void]$sb.AppendLine('$tableCols = @(& {' + $Columns.ToString() + '})')
        [void]$sb.AppendLine('New-UDTable -Data $tableData -Columns $tableCols -ShowSort -ShowPagination -PageSize ' + $PageSize + ' -Dense -ShowSearch')

        if (-not $RefreshInterval) {
            [void]$sb.AppendLine('New-UDButton -Text "Refresh" -OnClick { Sync-UDElement -Id ''' + $Id + ''' }')
        }

        $splat = @{
            Id      = $Id
            Content = [ScriptBlock]::Create($sb.ToString())
        }

        if ($RefreshInterval) {
            $splat['AutoRefresh']         = $true
            $splat['AutoRefreshInterval'] = $RefreshInterval
        }

        New-UDDynamic @splat
    }
}