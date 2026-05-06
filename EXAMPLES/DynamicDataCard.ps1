$newDataCardSplat = @{
    Title = 'Active Processes'
    Value = { (Get-Process).Count }
    RefreshInterval = 30
    Style = @{ borderLeft = '4px solid #1976d2'; borderRadius = '8px' }
}

New-DataCard @newDataCardSplat 