function New-UDDataCard {
    <#
    .SYNOPSIS
        Creates a metric or status card component for use in PowerShell Universal dashboards.

    .DESCRIPTION
        Renders a New-UDCard with a title, a dynamically evaluated value, an optional subtitle,
        and an italicized 'Last updated' timestamp in the bottom-right corner.

        The card structure, title, and subtitle are rendered as standard PSU components.
        Only the value and timestamp are wrapped in a New-UDDynamic endpoint so they
        re-execute on each refresh cycle without re-rendering the full card.

        When RefreshInterval is provided the dynamic region auto-refreshes on that interval.
        When omitted the card renders once; use Sync-UDElement targeting the Id to refresh manually.

    .PARAMETER Id
        The ID of the inner dynamic region. Use this with Sync-UDElement to trigger a manual refresh.
        Defaults to a new GUID if not specified.

    .PARAMETER Title
        The heading displayed above the value. Rendered as an overline-style label.

    .PARAMETER Value
        A scriptblock that returns the value to display prominently in the card.
        Executed inside the dynamic endpoint on every refresh cycle.

    .PARAMETER Subtitle
        Optional secondary text displayed beneath the title. Rendered once at page load —
        not re-evaluated on refresh.

    .PARAMETER Style
        A hashtable of CSS styles applied to the card element. Controls background color,
        border, box shadow, border-radius, and any other card-level presentation.

    .PARAMETER ValueColor
        CSS color string applied to the value text. Defaults to '#1976d2' (Material UI primary blue).

    .PARAMETER RefreshInterval
        The number of seconds between automatic refreshes of the value and timestamp.
        When omitted the card does not auto-refresh.

    .EXAMPLE
        New-UDDataCard -Title 'Active Users' -Value { (Get-Process).Count } -RefreshInterval 30 -Style @{ borderLeft = '4px solid #1976d2'; borderRadius = '8px' }

        Displays a process-count metric card with a blue left accent bar, auto-refreshing every 30 seconds.

    .EXAMPLE
        New-UDDataCard -Title 'Service Status' -Value { 'Healthy' } -ValueColor 'green' -Subtitle 'All systems operational'

        Displays a status card with a green value and a static descriptive subtitle.

    .EXAMPLE
        New-UDDataCard -Id 'backup-card' -Title 'Last Backup' -Value { Get-LatestBackupDate }
        Sync-UDElement -Id 'backup-card'

        Renders a card that can be manually refreshed by calling Sync-UDElement with its Id.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Id,

        [Parameter(Mandatory)]
        [String]
        $Title,

        [Parameter(Mandatory)]
        [ScriptBlock]
        $Value,

        [Parameter()]
        [Int32]
        $RefreshInterval,

        [Parameter()]
        [String]
        $Subtitle,

        [Parameter()]
        [Hashtable]
        $Style = @{},

        [Parameter()]
        [String]
        $ValueColor = '#1976d2'
    )

    end {
        $dynamicId = if ($Id) { $Id } else { [System.Guid]::NewGuid().ToString() }

        $dynContent = [ScriptBlock]::Create(
            '$v = & {' + $Value.ToString() + '}; ' +
            'New-UDTypography -Text "$v" -Variant h3 -Style @{ color = ''' + $ValueColor + '''; fontWeight = ''700''; lineHeight = ''1.2''; margin = ''4px 0'' }; ' +
            'New-UDTypography -Text (''Last updated: '' + (Get-Date).ToString(''yyyy-MM-dd HH:mm:ss'')) -Variant caption -Style @{ fontStyle = ''italic''; color = ''#bdbdbd''; fontSize = ''0.7rem''; display = ''block''; textAlign = ''right''; marginTop = ''16px'' }'
        )

        $dynSplat = @{ Id = $dynamicId; Content = $dynContent }

        if ($RefreshInterval) {
            $dynSplat['AutoRefresh']         = $true
            $dynSplat['AutoRefreshInterval'] = $RefreshInterval
        }

        New-UDCard -Style $Style -Content {
            New-UDElement -Tag 'div' -Attributes @{
                style = @{ display = 'flex'; flexDirection = 'column'; padding = '8px 4px'; minHeight = '80px' }
            } -Content {
                New-UDTypography -Text $Title -Variant overline -Style @{ color = '#757575'; letterSpacing = '0.1em'; fontSize = '0.7rem' }

                if ($Subtitle) {
                    New-UDTypography -Text $Subtitle -Variant body2 -Style @{ color = '#9e9e9e'; marginTop = '2px' }
                }

                New-UDDynamic @dynSplat
            }
        }
    }
}
