New-UDApp -Title 'A11y Wrapper Demo' -Content {

    New-UDTypography -Text 'New-UDA11yWrapper Examples' -Variant h4 -Style @{ marginBottom = '24px' }

    # ── Basic labeled region ──────────────────────────────────────────────────
    New-UDTypography -Text 'Search Region' -Variant subtitle1 -Style @{ marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'A div wrapper gives screen readers a named region for a composite control.' -Style @{ marginBottom = '12px' }

    New-UDA11yWrapper -AriaLabel 'Site search' -Style @{ display = 'flex'; gap = '8px'; alignItems = 'center' } -Content {
        New-UDTextbox -Id 'searchInput' -Placeholder 'Search...'
        New-UDButton -Text 'Go' -Variant contained -OnClick {
            $term = (Get-UDElement -Id 'searchInput').value
            Show-UDToast -Message "Searching for: $term"
        }
    }

    # ── ARIA group role on a fieldset ─────────────────────────────────────────
    New-UDTypography -Text 'Radio Group (fieldset + group role)' -Variant subtitle1 -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Using -Tag fieldset and -Role group lets assistive technology announce the group label before reading the individual options.' -Style @{ marginBottom = '12px' }

    New-UDA11yWrapper -Tag 'fieldset' -Role 'group' -AriaLabel 'Notification frequency' `
        -Style @{ border = '1px solid #e0e0e0'; borderRadius = '8px'; padding = '16px' } -Content {
        New-UDRadioGroup -Id 'freqGroup' -Label 'Frequency' -OnChange { } -Content {
            New-UDRadio -Value 'daily' -Label 'Daily'
            New-UDRadio -Value 'weekly' -Label 'Weekly'
            New-UDRadio -Value 'never' -Label 'Never'
        }
    }

    # ── Labeled table region ──────────────────────────────────────────────────
    New-UDTypography -Text 'Table Region' -Variant subtitle1 -Style @{ marginTop = '32px'; marginBottom = '8px' }
    New-UDAlert -Severity 'info' -Text 'Wrapping a table gives screen readers a landmark label before announcing table navigation.' -Style @{ marginBottom = '12px' }

    New-UDA11yWrapper -AriaLabel 'Running processes' -Content {
        $columns = @(
            New-UDTableColumn -Property 'Name' -Title 'Name' -ShowSort
            New-UDTableColumn -Property 'CPU' -Title 'CPU'
            New-UDTableColumn -Property 'Id' -Title 'PID'
        )
        $data = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, Id
        New-UDTable -Data $data -Columns $columns -ShowSearch -ShowPagination -PageSize 5
    }
}
