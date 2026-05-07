function New-PageHeader {
    <#
    .SYNOPSIS
        Creates a structured page header component for use in PowerShell Universal dashboards.

    .DESCRIPTION
        Renders a standardised top-of-page header block containing a title, optional icon,
        optional subtitle, optional action buttons, optional breadcrumb trail, optional help
        alert, and optional metadata chips or labels.

        The layout is built from two stacked rows. The first row places the icon and title
        group on the left and any action controls on the right. Below that, breadcrumbs,
        a help alert, and metadata are each rendered when their parameter is supplied.

        The component is purely presentational and renders once at page load.

    .PARAMETER Title
        The primary heading text. Rendered as an h4-variant New-UDTypography element.

    .PARAMETER Subtitle
        Optional secondary text displayed beneath the title.
        Rendered as a body2-variant New-UDTypography element.

    .PARAMETER Icon
        Optional FontAwesome icon name (without the 'fa-' prefix) displayed to the left
        of the title. Passed directly to New-UDIcon.

    .PARAMETER Actions
        Optional scriptblock whose output is rendered in a row on the right-hand side of
        the header. Use this for buttons, dropdowns, or other interactive controls.

    .PARAMETER Breadcrumb
        Optional array representing the navigation path to the current page.
        Each item is either a plain string (label only, no link) or a hashtable
        with a 'Label' key and an optional 'Url' key. Items with a Url are rendered
        as New-UDLink elements; items without are rendered as plain text.
        Rendered using New-UDBreadcrumbs.

    .PARAMETER HelpText
        Optional explanatory text rendered as an info-severity New-UDAlert beneath the
        title row. Use this to surface context-sensitive guidance to users.

    .PARAMETER Metadata
        Optional scriptblock whose output is rendered in a horizontal row beneath the
        title row. Use this for status badges, timestamps, or key/value chips.

    .PARAMETER Style
        Optional hashtable of CSS styles applied to the outermost container stack.
        Use this to control padding, margin, background, or border on the header block.

    .EXAMPLE
        New-PageHeader -Title 'Server Inventory'

        Renders a minimal header with only a title.

    .EXAMPLE
        New-PageHeader -Title 'Server Inventory' -Subtitle 'All registered hosts' -Icon 'server' -Breadcrumb @(
            @{ Label = 'Home';           Url = '/home' }
            @{ Label = 'Infrastructure'; Url = '/infrastructure' }
            'Servers'
        )

        Renders a header with an icon, subtitle, and breadcrumb trail where the first
        two items are clickable links and the last is plain text.

    .EXAMPLE
        $newPageHeaderSplat = @{
            Title       = 'Scheduled Jobs'
            Subtitle    = 'Manage automation tasks'
            Icon        = 'calendar'
            Breadcrumb = @('Home', 'Automation', 'Jobs')
            HelpText    = 'Changes take effect on the next scheduler cycle.'
            Actions     = { New-UDButton -Text 'New Job' -OnClick { } }
            Metadata    = { New-UDChip -Label '12 Active' }
            Style       = @{ padding = '16px'; marginBottom = '24px' }
        }
        New-PageHeader @newPageHeaderSplat

        Renders a fully populated header with all optional regions and custom spacing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Subtitle,

        [Parameter()]
        [string]
        $Icon,

        [Parameter()]
        [scriptblock]
        $Actions,

        [Parameter()]
        [object[]]
        $Breadcrumb,

        [Parameter()]
        [string]
        $HelpText,

        [Parameter()]
        [scriptblock]
        $Metadata,

        [Parameter()]
        [hashtable]
        $Style = @{}
    )

    end {
        New-UDElement -Tag 'div' -Attributes @{ style = $Style } -Content {
        New-UDStack -Direction column -Spacing 1 -Content {
            New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Content {
                New-UDStack -Direction row -Spacing 2 -AlignItems center -Content {
                    if ($Icon) {
                        New-UDIcon -Icon $Icon -Size lg
                    }

                    New-UDStack -Direction column -Spacing 0 -Content {
                        New-UDTypography -Variant h4 -Text $Title

                        if ($Subtitle) {
                            New-UDTypography -Variant body2 -Text $Subtitle
                        }
                    }
                }

                if ($Actions) {
                    New-UDStack -Direction row -Spacing 1 -Content $Actions
                }
            }

            if ($Breadcrumb) {
                New-UDBreadcrumbs -Children {
                    foreach ($crumb in $Breadcrumb) {
                        if ($crumb -is [hashtable] -and $crumb.Url) {
                            New-UDLink -Url $crumb.Url -Text $crumb.Label
                        } else {
                            $label = if ($crumb -is [hashtable]) { $crumb.Label } else { [string]$crumb }
                            New-UDTypography -Text $label -Variant body2
                        }
                    }
                }
            }

            if ($HelpText) {
                New-UDAlert -Severity info -Text $HelpText
            }

            if ($Metadata) {
                New-UDStack -Direction row -Spacing 2 -Content $Metadata
            }
        }
        }
    }
}
