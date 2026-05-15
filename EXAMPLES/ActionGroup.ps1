New-UDApp -Title 'Action Group Demo' -Content {

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
        $direction  = if ($dirElement.value) { $dirElement.value } else { 'row' }

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