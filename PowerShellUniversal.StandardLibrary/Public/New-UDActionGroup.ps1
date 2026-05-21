function New-UDActionGroup {
    <#
    .SYNOPSIS
        Renders a group of buttons arranged in a stack layout.

    .DESCRIPTION
        Wraps one or more button components in a New-UDStack, controlling their
        layout direction and spacing. The container shrinks to fit its content
        by default (width: fit-content) and accepts optional CSS overrides via Style.

    .PARAMETER Id
        Optional element ID for the wrapping div. Use with Sync-UDElement to
        target the group for dynamic refresh.

    .PARAMETER Button
        One or more button hashtables to render inside the group. Each item
        should be the output of New-UDButton or a compatible component.

    .PARAMETER Direction
        Flex direction for the button stack. Accepted values:
            row            - left to right (default)
            column         - top to bottom
            row-reverse    - right to left
            column-reverse - bottom to top

    .PARAMETER Style
        A hashtable of CSS styles applied to the outer container div. These
        are merged with the default style (width: fit-content), with any
        provided values taking precedence.

    .PARAMETER Spacing
        Controls the gap between buttons using MUI spacing units. Accepts an
        integer value where each unit equals 8px (e.g. 1 = 8px, 2 = 16px).
        Defaults to 2 (16px).

    .EXAMPLE
        New-UDActionGroup -Button @(
            New-UDButton -Text 'Save' -Color primary -OnClick { Save-Data }
            New-UDButton -Text 'Cancel' -Color default -OnClick { Hide-UDModal }
        )

        Renders a horizontal row of two buttons that shrinks to fit their content.

    .EXAMPLE
        New-UDActionGroup -Direction column -Style @{ padding = '16px' } -Button @(
            New-UDButton -Text 'Deploy' -OnClick { Start-Deployment }
            New-UDButton -Text 'Rollback' -OnClick { Start-Rollback }
            New-UDButton -Text 'Destroy' -OnClick { Start-Destroy }
        )

        Renders three buttons stacked vertically inside a padded container.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [String]
        $Id,
        
        [Parameter(Mandatory)]
        [Hashtable[]]
        $Button,

        [Parameter()]
        [ValidateSet('row', 'column', 'row-reverse', 'column-reverse')]
        [String]
        $Direction = 'row',

        [Parameter()]
        [Int]
        $Spacing = 2,

        [Parameter()]
        [Hashtable]
        $Style
    )

    end {
        $baseStyle = @{ width = 'fit-content' }
        $mergedStyle = $baseStyle + $(if ($Style) { $Style } else { @{} })

        New-UDElement -Tag div -Attributes @{ style = $mergedStyle } -Content {
            New-UDStack -Direction $Direction -Spacing $Spacing -Children {

                $Button | Foreach-Object -Process {
                    $_
                }
            }
        }
    }
}