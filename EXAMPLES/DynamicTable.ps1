New-UDApp -Title 'Dynamic Table Demo' -Content { 

    $newDynamicTableSplat = @{
        Id      = 'process-table'
        Data    = {
            Get-Process | Select-Object -First 50 Name, Id, CPU, WorkingSet
        }
        Columns = {
            New-UDTableColumn -Property Name -Title 'Name' -ShowSort
            New-UDTableColumn -Property Id -Title 'PID'-ShowSort
            New-UDTableColumn -Property CPU -Title 'CPU (s)' -ShowSort -Render {
                '{0:N2}' -f [double]$EventData.CPU
            }
            New-UDTableColumn -Property WorkingSet -Title 'Memory (MB)' -ShowSort -Render {
                '{0:N0}' -f ($EventData.WorkingSet / 1MB)
            }
        }
    }

    New-UDDynamicTable @newDynamicTableSplat

}