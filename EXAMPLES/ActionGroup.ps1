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
            New-UDButton -Text 'Primary' -Variant contained -Color primary -OnClick { Show-UDToast -Message 'Primary clicked' -MessageColor '#1976d2' }
            New-UDButton -Text 'Secondary' -Variant contained -Color secondary -OnClick { Show-UDToast -Message 'Secondary clicked' -MessageColor '#9c27b0' }
            New-UDButton -Text 'Error' -Variant contained -Color error -OnClick { Show-UDToast -Message 'Error clicked' -MessageColor red }
        )

        # --- Outlined buttons ---
        New-UDTypography -Text 'Outlined' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px'; background = '#ffffff'; borderRadius = '8px'; border = '1px solid #e0e0e0' } -Button @(
            New-UDButton -Text 'Save' -Variant outlined -Color primary -Icon (New-UDIcon -Icon save) -OnClick { Show-UDToast -Message 'Saved!' -MessageColor green }
            New-UDButton -Text 'Edit' -Variant outlined -Color default -Icon (New-UDIcon -Icon edit) -OnClick { Show-UDToast -Message 'Editing...' -MessageColor '#555' }
            New-UDButton -Text 'Delete' -Variant outlined -Color error -Icon (New-UDIcon -Icon trash) -OnClick { Show-UDToast -Message 'Deleted!' -MessageColor red }
        )

        # --- Text / ghost buttons ---
        New-UDTypography -Text 'Text (Ghost)' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px' } -Button @(
            New-UDButton -Text 'Accept' -Variant text -Color primary -OnClick { Show-UDToast -Message 'Accepted' -MessageColor green }
            New-UDButton -Text 'Ignore' -Variant text -Color default -OnClick { Show-UDToast -Message 'Ignored' -MessageColor '#555' }
            New-UDButton -Text 'Reject' -Variant text -Color error -OnClick { Show-UDToast -Message 'Rejected' -MessageColor red }
        )

        # --- Custom styled buttons ---
        New-UDTypography -Text 'Custom Styled' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px'; background = '#1e1e2e'; borderRadius = '8px' } -Button @(
            New-UDButton -Text 'Deploy' -Style @{ background = '#4caf50'; color = '#fff'; fontWeight = '700' } -OnClick { Show-UDToast -Message 'Deploying...' -MessageColor '#4caf50' }
            New-UDButton -Text 'Rollback' -Style @{ background = '#ff9800'; color = '#fff'; fontWeight = '700' } -OnClick { Show-UDToast -Message 'Rolling back' -MessageColor '#ff9800' }
            New-UDButton -Text 'Destroy' -Style @{ background = '#f44336'; color = '#fff'; fontWeight = '700' } -OnClick { Show-UDToast -Message '💀 Destroyed' -MessageColor red }
        )

        # --- Pill buttons ---
        New-UDTypography -Text 'Pill' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px'; background = '#f5f5f5'; borderRadius = '8px' } -Button @(
            New-UDButton -Text 'Approve' -Style @{ borderRadius = '999px'; background = '#4caf50'; color = '#fff'; padding = '6px 20px'; fontWeight = '600' } -OnClick { Show-UDToast -Message 'Approved' -MessageColor '#4caf50' }
            New-UDButton -Text 'Review' -Style @{ borderRadius = '999px'; background = '#1976d2'; color = '#fff'; padding = '6px 20px'; fontWeight = '600' } -OnClick { Show-UDToast -Message 'Sent for review' -MessageColor '#1976d2' }
            New-UDButton -Text 'Reject' -Style @{ borderRadius = '999px'; background = '#f44336'; color = '#fff'; padding = '6px 20px'; fontWeight = '600' } -OnClick { Show-UDToast -Message 'Rejected' -MessageColor red }
        )

        # --- Pill outlined ---
        New-UDTypography -Text 'Pill Outlined' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDActionGroup -Direction $direction -Style @{ padding = '12px' } -Button @(
            New-UDButton -Text '+ Follow' -Style @{ borderRadius = '999px'; border = '2px solid #1976d2'; color = '#1976d2'; padding = '5px 18px'; background = 'transparent'; fontWeight = '600' } -OnClick { Show-UDToast -Message 'Following!' -MessageColor '#1976d2' }
            New-UDButton -Text '★ Favorite' -Style @{ borderRadius = '999px'; border = '2px solid #ff9800'; color = '#ff9800'; padding = '5px 18px'; background = 'transparent'; fontWeight = '600' } -OnClick { Show-UDToast -Message 'Added to favourites' -MessageColor '#ff9800' }
            New-UDButton -Text '⚑ Flag' -Style @{ borderRadius = '999px'; border = '2px solid #9c27b0'; color = '#9c27b0'; padding = '5px 18px'; background = 'transparent'; fontWeight = '600' } -OnClick { Show-UDToast -Message 'Flagged' -MessageColor '#9c27b0' }
        )

        # --- Chip / tag style (small, low-emphasis) ---
        New-UDTypography -Text 'Chip / Tag' -Variant subtitle1 -Style @{ marginTop = '24px'; marginBottom = '4px' }
        New-UDTypography -Text 'Compact clickable labels — useful for filters, categories, or status toggles.' -Variant caption -Style @{ color = '#757575'; marginBottom = '8px'; display = 'block' }
        New-UDActionGroup -Direction $direction -Spacing 1 -Style @{ padding = '12px'; background = '#fafafa'; borderRadius = '8px'; border = '1px solid #e0e0e0' } -Button @(
            New-UDButton -Text 'Active' -Style @{ borderRadius = '999px'; background = '#e8f5e9'; color = '#2e7d32'; fontSize = '0.75rem'; padding = '3px 12px'; fontWeight = '600'; textTransform = 'none'; minWidth = '0' } -OnClick { Show-UDToast -Message 'Filter: Active' -MessageColor '#2e7d32' }
            New-UDButton -Text 'Pending' -Style @{ borderRadius = '999px'; background = '#fff8e1'; color = '#f57f17'; fontSize = '0.75rem'; padding = '3px 12px'; fontWeight = '600'; textTransform = 'none'; minWidth = '0' } -OnClick { Show-UDToast -Message 'Filter: Pending' -MessageColor '#f57f17' }
            New-UDButton -Text 'Failed' -Style @{ borderRadius = '999px'; background = '#ffebee'; color = '#c62828'; fontSize = '0.75rem'; padding = '3px 12px'; fontWeight = '600'; textTransform = 'none'; minWidth = '0' } -OnClick { Show-UDToast -Message 'Filter: Failed' -MessageColor red }
            New-UDButton -Text 'Archived' -Style @{ borderRadius = '999px'; background = '#f3e5f5'; color = '#6a1b9a'; fontSize = '0.75rem'; padding = '3px 12px'; fontWeight = '600'; textTransform = 'none'; minWidth = '0' } -OnClick { Show-UDToast -Message 'Filter: Archived' -MessageColor '#6a1b9a' }
            New-UDButton -Text 'Disabled' -Style @{ borderRadius = '999px'; background = '#eeeeee'; color = '#9e9e9e'; fontSize = '0.75rem'; padding = '3px 12px'; fontWeight = '600'; textTransform = 'none'; minWidth = '0'; cursor = 'not-allowed' } -OnClick { Show-UDToast -Message 'This one is disabled' -MessageColor '#9e9e9e' }
        )
    }
}