# ============================================================
#  New-UDFormTemplate — Example Gallery
#
#  Paste the content of this file into a PowerShell Universal
#  App or Dashboard page to see each form in action.
# ============================================================

New-UDApp -Title 'Contact Form Gallery' -Content {

    New-UDPageHeader -Title 'Form Template Gallery' -Subtitle 'New-UDFormTemplate examples' -Icon 'wpforms'

    # ── Simple / flat styles ──────────────────────────────────
    $flat = @{ marginBottom = '24px'; borderRadius = '6px'; border = '1px solid #e0e0e0'; boxShadow = 'none' }

    # ── Modern styles — rounded, elevated, colour-accented ────
    $modernBlue   = @{ marginBottom = '24px'; borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #1976d2' }
    $modernGreen  = @{ marginBottom = '24px'; borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #2e7d32' }
    $modernRed    = @{ marginBottom = '24px'; borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #d32f2f' }
    $modernAmber  = @{ marginBottom = '24px'; borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #f57c00' }
    $modernPurple = @{ marginBottom = '24px'; borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #7b1fa2' }
    $modernTeal   = @{ marginBottom = '24px'; borderRadius = '18px'; boxShadow = '0 8px 30px rgba(0,0,0,0.10)'; borderTop = '4px solid #00695c' }

    # ----------------------------------------------------------
    # Pair 1: Newsletter (flat) & Feedback (modern blue) — side by side
    # ----------------------------------------------------------
    New-UDStack -Direction row -Spacing 3 -Content {
        New-UDCard -Title 'Newsletter Signup' -Style $flat -Content {
            $p = @{
                Template      = 'Email'
                SubmitText    = 'Subscribe'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Subscribed: $($EventData.txtEmail)" }
            }
            New-UDFormTemplate @p
        }
        New-UDCard -Title 'Feedback' -Style $modernBlue -Content {
            $p = @{
                Template      = 'Feedback'
                SubmitText    = 'Send Feedback'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Feedback received: $($EventData.selCategory)" }
            }
            New-UDFormTemplate @p
        }
    }

    # ----------------------------------------------------------
    # Pair 2: Password Reset (flat) & Confirmation modal (modern red) — side by side
    # ----------------------------------------------------------
    New-UDStack -Direction row -Spacing 3 -Content {
        New-UDCard -Title 'Password Reset' -Style $flat -Content {
            $p = @{
                Template      = 'PasswordReset'
                SubmitText    = 'Request Reset'
                ButtonVariant = 'outlined'
                OnSubmit      = { Show-UDToast -Message "Reset link sent to $($EventData.txtEmail)" }
            }
            New-UDFormTemplate @p
        }
        New-UDCard -Title 'Confirmation Prompt' -Style $modernRed -Content {
            New-UDTypography -Text 'Opens a modal confirmation dialog with Submit and Cancel buttons.' -Variant 'body2' -Style @{ marginBottom = '16px'; color = '#888' }
            $btn = @{
                Text    = 'Delete Resource'
                Variant = 'contained'
                Color   = 'error'
                Icon    = (New-UDIcon -Icon 'trash')
                OnClick = {
                    Show-UDModal -Content {
                        $p = @{
                            Template      = 'Confirmation'
                            SubmitText    = 'Yes, Delete'
                            CancelText    = 'Cancel'
                            OnSubmit      = { Show-UDToast -Message 'Resource deleted.' -MessageColor 'red'; Hide-UDModal }
                            OnCancel      = { Hide-UDModal }
                        }
                        New-UDFormTemplate @p
                    }
                }
            }
            New-UDButton @btn
        }
    }

    # ----------------------------------------------------------
    # Pair 3: Simple Registration (modern green) & Service Request (flat)
    # ----------------------------------------------------------
    New-UDStack -Direction row -Spacing 3 -Content {
        New-UDCard -Title 'Simple Registration' -Style $modernGreen -Content {
            $p = @{
                Template      = 'SimpleRegistration'
                SubmitText    = 'Create Account'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Account created for $($EventData.txtFirstName) $($EventData.txtLastName)" }
            }
            New-UDFormTemplate @p
        }
        New-UDCard -Title 'Service Request' -Style $flat -Content {
            $p = @{
                Template      = 'ServiceRequest'
                SubmitText    = 'Submit Ticket'
                ButtonVariant = 'outlined'
                OnSubmit      = { Show-UDToast -Message "Ticket submitted for $($EventData.txtRequesterName)" }
            }
            New-UDFormTemplate @p
        }
    }

    # ----------------------------------------------------------
    # Pair 4: Change Request (modern amber) & Shipping (modern teal)
    # ----------------------------------------------------------
    New-UDStack -Direction row -Spacing 3 -Content {
        New-UDCard -Title 'Change Request' -Style $modernAmber -Content {
            $p = @{
                Template      = 'ChangeRequest'
                SubmitText    = 'Raise Change'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Change request raised: $($EventData.txtTitle)" }
            }
            New-UDFormTemplate @p
        }
        New-UDCard -Title 'Shipping Address' -Style $modernTeal -Content {
            $p = @{
                Template      = 'Shipping'
                SubmitText    = 'Save Address'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Address saved for $($EventData.txtFirstName) $($EventData.txtLastName)" }
            }
            New-UDFormTemplate @p
        }
    }

    # ----------------------------------------------------------
    # Pair 5: User Onboarding (modern purple) — half-width
    # ----------------------------------------------------------
    New-UDElement -Tag 'div' -Attributes @{ style = @{ width = '50%' } } -Content {
        New-UDCard -Title 'User Onboarding' -Style $modernPurple -Content {
            $p = @{
                Template      = 'UserOnboarding'
                SubmitText    = 'Provision User'
                ButtonVariant = 'contained'
                OnSubmit      = { Show-UDToast -Message "Provisioning $($EventData.txtFirstName) $($EventData.txtLastName) — starts $($EventData.datStartDate)" }
            }
            New-UDFormTemplate @p
        }
    }

}
