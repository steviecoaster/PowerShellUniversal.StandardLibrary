function New-UDA11yWrapper {
    <#
    .SYNOPSIS
        Wraps one or more PSU components in an accessible container element.

    .DESCRIPTION
        Renders a New-UDElement container (div by default) around any PSU
        components — buttons, textboxes, radio buttons, tables, etc. — and
        applies an aria-label via the Attributes parameter. Use this when an
        existing component does not surface an aria-label parameter directly,
        or when you need to label a composite region for screen-reader users.

    .PARAMETER Id
        Element ID for the wrapper element. Defaults to a new GUID. Use with
        Sync-UDElement to target the container for dynamic refresh.

    .PARAMETER Content
        Scriptblock containing the PSU components to render inside the wrapper.

    .PARAMETER AriaLabel
        Value for the aria-label attribute on the wrapping element.

    .PARAMETER Tag
        HTML tag to use for the wrapper element. Defaults to 'div'. Use 'span'
        for inline contexts, or a semantic tag such as 'section' or 'fieldset'
        where appropriate.

    .PARAMETER Role
        Value for the ARIA role attribute on the wrapper element. Use when the
        chosen tag does not carry an implicit role that matches the intent (e.g.
        role='group' for a set of related form controls, role='region' for a
        landmark area).

    .PARAMETER Style
        A hashtable of CSS styles applied directly to the wrapper element.
        Defaults to an empty hashtable (no inline styles).

    .EXAMPLE
        New-UDA11yWrapper -AriaLabel 'Search controls' -Content {
            New-UDTextbox -Placeholder 'Search...'
            New-UDButton -Text 'Go' -OnClick { Invoke-Search }
        }

        Wraps a textbox and button in a labeled div so assistive technology
        can identify the region.

    .EXAMPLE
        New-UDA11yWrapper -Tag 'fieldset' -Role 'group' `
            -AriaLabel 'Notification preferences' -Content {
            New-UDRadioGroup -Label 'Frequency' -Children {
                New-UDRadio -Value 'daily' -Label 'Daily'
                New-UDRadio -Value 'weekly' -Label 'Weekly'
            }
        }

        Wraps a radio group in a semantic fieldset with an explicit ARIA group
        role and label.

    .EXAMPLE
        New-UDA11yWrapper -AriaLabel 'Active sessions table' -Content {
            New-UDTable -Data $Sessions -Columns $Columns
        }

        Labels a table region for screen readers that announce the wrapper when
        focus enters.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$Id = (New-Guid),

        [Parameter(Mandatory)]
        [scriptblock]$Content,

        [Parameter(Mandatory)]
        [string]$AriaLabel,

        [Parameter()]
        [string]$Tag = 'div',

        [Parameter()]
        [string]$Role,

        [Parameter()]
        [hashtable]$Style = @{}
    )

    $attributes = @{
        id = $Id
        'aria-label' = $AriaLabel
        style = $Style
    }

    if ($Role) {
        $attributes['role'] = $Role
    }

    New-UDElement -Tag $Tag -Content $Content -Attributes $attributes
}
