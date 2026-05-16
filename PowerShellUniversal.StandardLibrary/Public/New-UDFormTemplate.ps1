function New-UDFormTemplate {
    <#
    .SYNOPSIS
        Renders a pre-built form using a named template.

    .DESCRIPTION
        Generates a New-UDForm populated with input controls and built-in field
        validation appropriate for the chosen template. The caller supplies the
        OnSubmit handler and, optionally, OnCancel. Within those script blocks,
        $EventData contains one property per field, keyed by the field IDs
        documented for each template below.

        Templates and their $EventData keys:

          SimpleRegistration
            txtFirstName, txtLastName, txtEmail, txtPassword, txtConfirmPassword
            Validates all fields are filled, email is well-formed, and both
            password fields match.

          Email
            txtEmail, txtFirstName (optional), txtLastName (optional)
            Validates that txtEmail is non-empty and well-formed. First and last
            name are collected but not required.

          Shipping
            txtFirstName, txtLastName, txtAddress1, txtAddress2 (optional),
            txtCity, txtState, txtZip, txtCountry
            Validates all required fields are filled.

          Feedback
            selCategory, txtMessage, txtEmail (optional)
            Validates category and message are non-empty.

          ChangeRequest
            txtTitle, txtAffectedSystem, selPriority, txtDescription, datRequestedDate
            Validates all fields are non-empty.

          ServiceRequest
            txtRequesterName, txtRequesterEmail, selCategory, selPriority, txtDescription
            Validates all fields are non-empty and email is well-formed.

          UserOnboarding
            txtFirstName, txtLastName, txtEmail, txtDepartment, txtJobTitle,
            txtManager, datStartDate
            Validates all fields are non-empty and email is well-formed.

          Confirmation
            No input fields. Renders a confirmation prompt with Submit and Cancel
            buttons. $EventData will be empty; use OnSubmit to perform the action
            and OnCancel to abort.

          PasswordReset
            txtUsername, txtEmail, txtReason (optional)
            Validates username and email are non-empty and email is well-formed.

    .PARAMETER Template
        The name of the form template to render. Accepted values:
        SimpleRegistration, Email, Shipping, Feedback, ChangeRequest,
        ServiceRequest, UserOnboarding, Confirmation, PasswordReset.

    .PARAMETER OnSubmit
        Script block executed when the form passes validation and the user clicks
        Submit. $EventData contains a property for every input field in the form.

    .PARAMETER OnCancel
        Optional script block executed when the user clicks Cancel. Typically
        used to close a modal or navigate away from the current page.

    .PARAMETER Id
        Optional ID applied to the underlying New-UDForm element. Defaults to a
        new GUID when not supplied.

    .PARAMETER SubmitText
        Label shown on the submit button. Defaults to 'Submit'. Passed directly
        to New-UDForm -SubmitText.

    .PARAMETER CancelText
        Label shown on the cancel button when OnCancel is provided. Defaults to
        'Cancel'. Passed directly to New-UDForm -CancelText.

    .PARAMETER ButtonVariant
        Visual style applied to the submit and cancel buttons. Accepted values:
        contained (filled), outlined, text (default). Passed directly to
        New-UDForm -ButtonVariant.

    .PARAMETER ClassName
        A CSS class name applied to the form element. Use this to target the
        form with a custom stylesheet loaded into your PSU app.

    .PARAMETER Style
        A hashtable of inline CSS styles applied to a div that wraps the entire
        form. Use this for quick layout tweaks such as max-width, padding, or
        background-color without needing a separate stylesheet.

    .EXAMPLE
        New-UDFormTemplate -Template SimpleRegistration -OnSubmit {
            Show-UDToast -Message "Welcome, $($EventData.txtFirstName)!"
        }

        Renders a registration form and greets the new user by first name on submit.

    .EXAMPLE
        New-UDFormTemplate -Template Shipping -OnSubmit {
            Save-ShippingAddress -Data $EventData
        } -OnCancel {
            Hide-UDModal
        }

        Renders a shipping address form inside a modal, saves data on submit, and
        closes the modal when the user cancels.

    .EXAMPLE
        New-UDFormTemplate -Template Email -OnSubmit {
            Add-NewsletterSubscriber -Email $EventData.txtEmail `
                                     -FirstName $EventData.txtFirstName `
                                     -LastName  $EventData.txtLastName
            Show-UDToast -Message 'You are subscribed!'
        }

        Renders a newsletter signup form and registers the subscriber on submit.

    .EXAMPLE
        New-UDFormTemplate -Template ServiceRequest -OnSubmit {
            New-HelpDeskTicket -Data $EventData
            Show-UDToast -Message "Ticket submitted. You will be contacted at $($EventData.txtRequesterEmail)."
        }

        Renders a help desk ticket form and creates a ticket record on submit.

    .EXAMPLE
        New-UDFormTemplate -Template Confirmation -OnSubmit {
            Remove-TargetResource -Id $resourceId
            Hide-UDModal
        } -OnCancel {
            Hide-UDModal
        }

        Renders a confirmation prompt inside a modal. Deletes the resource on
        confirm and closes the modal on either action.

    .EXAMPLE
        New-UDFormTemplate -Template UserOnboarding -OnSubmit {
            New-ADUser -GivenName  $EventData.txtFirstName `
                       -Surname   $EventData.txtLastName   `
                       -UserPrincipalName $EventData.txtEmail
            Show-UDToast -Message 'Account created.'
        }

        Renders a new-employee onboarding form and provisions an AD account on submit.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('SimpleRegistration', 'Email', 'Shipping', 'Feedback',
                     'ChangeRequest', 'ServiceRequest', 'UserOnboarding',
                     'Confirmation', 'PasswordReset')]
        [String]
        $Template,

        [Parameter(Mandatory)]
        [ScriptBlock]
        $OnSubmit,

        [Parameter()]
        [ScriptBlock]
        $OnCancel,

        [Parameter()]
        [String]
        $Id,

        [Parameter()]
        [String]
        $SubmitText,

        [Parameter()]
        [String]
        $CancelText,

        [Parameter()]
        [ValidateSet('contained', 'outlined', 'text')]
        [String]
        $ButtonVariant,

        [Parameter()]
        [String]
        $ClassName,

        [Parameter()]
        [Hashtable]
        $Style
    )

    end {
        $formId    = if ($Id) { $Id } else { [System.Guid]::NewGuid().ToString() }
        $formSplat = @{
            Id       = $formId
            OnSubmit = $OnSubmit
        }
        if ($OnCancel)      { $formSplat['OnCancel']      = $OnCancel }
        if ($SubmitText)    { $formSplat['SubmitText']    = $SubmitText }
        if ($CancelText)    { $formSplat['CancelText']    = $CancelText }
        if ($ButtonVariant) { $formSplat['ButtonVariant'] = $ButtonVariant }
        if ($ClassName)     { $formSplat['ClassName']     = $ClassName }

        switch ($Template) {

            'SimpleRegistration' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtFirstName)) {
                        New-UDFormValidationResult -ValidationError 'First name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtLastName)) {
                        New-UDFormValidationResult -ValidationError 'Last name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtEmail) -or
                        $EventData.txtEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
                        New-UDFormValidationResult -ValidationError 'A valid email address is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtPassword)) {
                        New-UDFormValidationResult -ValidationError 'Password is required.'; return
                    }
                    if ($EventData.txtPassword -ne $EventData.txtConfirmPassword) {
                        New-UDFormValidationResult -ValidationError 'Passwords do not match.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtFirstName' -Label 'First Name'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtLastName' -Label 'Last Name'
                        }
                    }
                    New-UDTextbox -Id 'txtEmail' -Label 'Email Address' -Type 'email'
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtPassword' -Label 'Password' -Type 'password'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtConfirmPassword' -Label 'Confirm Password' -Type 'password'
                        }
                    }
                }
            }

            'Email' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtEmail) -or
                        $EventData.txtEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
                        New-UDFormValidationResult -ValidationError 'A valid email address is required.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtFirstName' -Label 'First Name (optional)'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtLastName' -Label 'Last Name (optional)'
                        }
                    }
                    New-UDTextbox -Id 'txtEmail' -Label 'Email Address' -Type 'email'
                }
            }

            'Shipping' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtFirstName)) {
                        New-UDFormValidationResult -ValidationError 'First name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtLastName)) {
                        New-UDFormValidationResult -ValidationError 'Last name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtAddress1)) {
                        New-UDFormValidationResult -ValidationError 'Address line 1 is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtCity)) {
                        New-UDFormValidationResult -ValidationError 'City is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtState)) {
                        New-UDFormValidationResult -ValidationError 'State / province is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtZip)) {
                        New-UDFormValidationResult -ValidationError 'ZIP / postal code is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtCountry)) {
                        New-UDFormValidationResult -ValidationError 'Country is required.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtFirstName' -Label 'First Name'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtLastName' -Label 'Last Name'
                        }
                    }
                    New-UDTextbox -Id 'txtAddress1' -Label 'Address Line 1'
                    New-UDTextbox -Id 'txtAddress2' -Label 'Address Line 2 (optional)'
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 5 -LargeSize 5 -Content {
                            New-UDTextbox -Id 'txtCity' -Label 'City'
                        }
                        New-UDColumn -SmallSize 4 -LargeSize 4 -Content {
                            New-UDTextbox -Id 'txtState' -Label 'State / Province'
                        }
                        New-UDColumn -SmallSize 3 -LargeSize 3 -Content {
                            New-UDTextbox -Id 'txtZip' -Label 'ZIP / Postal Code'
                        }
                    }
                    New-UDTextbox -Id 'txtCountry' -Label 'Country'
                }
            }

            'Feedback' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.selCategory)) {
                        New-UDFormValidationResult -ValidationError 'Please select a category.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtMessage)) {
                        New-UDFormValidationResult -ValidationError 'Message is required.'; return
                    }
                    if (-not [string]::IsNullOrWhiteSpace($EventData.txtEmail) -and
                        $EventData.txtEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
                        New-UDFormValidationResult -ValidationError 'Email must be a valid address if provided.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDSelect -Id 'selCategory' -Label 'Category' -Option {
                        New-UDSelectOption -Name 'Bug Report'       -Value 'Bug Report'
                        New-UDSelectOption -Name 'Feature Request'  -Value 'Feature Request'
                        New-UDSelectOption -Name 'General'          -Value 'General'
                        New-UDSelectOption -Name 'Other'            -Value 'Other'
                    }
                    New-UDTextbox -Id 'txtMessage' -Label 'Message' -Multiline -Rows 5
                    New-UDTextbox -Id 'txtEmail'   -Label 'Email Address (optional)' -Type 'email'
                }
            }

            'ChangeRequest' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtTitle)) {
                        New-UDFormValidationResult -ValidationError 'Title is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtAffectedSystem)) {
                        New-UDFormValidationResult -ValidationError 'Affected system is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.selPriority)) {
                        New-UDFormValidationResult -ValidationError 'Please select a priority.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtDescription)) {
                        New-UDFormValidationResult -ValidationError 'Description is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.datRequestedDate)) {
                        New-UDFormValidationResult -ValidationError 'Requested date is required.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDTextbox -Id 'txtTitle' -Label 'Change Title'
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 8 -LargeSize 8 -Content {
                            New-UDTextbox -Id 'txtAffectedSystem' -Label 'Affected System'
                        }
                        New-UDColumn -SmallSize 4 -LargeSize 4 -Content {
                            New-UDSelect -Id 'selPriority' -Label 'Priority' -Option {
                                New-UDSelectOption -Name 'Low'      -Value 'Low'
                                New-UDSelectOption -Name 'Medium'   -Value 'Medium'
                                New-UDSelectOption -Name 'High'     -Value 'High'
                                New-UDSelectOption -Name 'Critical' -Value 'Critical'
                            }
                        }
                    }
                    New-UDTextbox    -Id 'txtDescription'   -Label 'Description'   -Multiline -Rows 4
                    New-UDDatePicker -Id 'datRequestedDate' -Label 'Requested Date'
                }
            }

            'ServiceRequest' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtRequesterName)) {
                        New-UDFormValidationResult -ValidationError 'Your name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtRequesterEmail) -or
                        $EventData.txtRequesterEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
                        New-UDFormValidationResult -ValidationError 'A valid email address is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.selCategory)) {
                        New-UDFormValidationResult -ValidationError 'Please select a category.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.selPriority)) {
                        New-UDFormValidationResult -ValidationError 'Please select a priority.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtDescription)) {
                        New-UDFormValidationResult -ValidationError 'Description is required.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtRequesterName' -Label 'Your Name'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtRequesterEmail' -Label 'Your Email' -Type 'email'
                        }
                    }
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDSelect -Id 'selCategory' -Label 'Category' -Option {
                                New-UDSelectOption -Name 'Access'   -Value 'Access'
                                New-UDSelectOption -Name 'Hardware' -Value 'Hardware'
                                New-UDSelectOption -Name 'Software' -Value 'Software'
                                New-UDSelectOption -Name 'Network'  -Value 'Network'
                                New-UDSelectOption -Name 'Other'    -Value 'Other'
                            }
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDSelect -Id 'selPriority' -Label 'Priority' -Option {
                                New-UDSelectOption -Name 'Low'      -Value 'Low'
                                New-UDSelectOption -Name 'Medium'   -Value 'Medium'
                                New-UDSelectOption -Name 'High'     -Value 'High'
                                New-UDSelectOption -Name 'Critical' -Value 'Critical'
                            }
                        }
                    }
                    New-UDTextbox -Id 'txtDescription' -Label 'Description' -Multiline -Rows 5
                }
            }

            'UserOnboarding' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtFirstName)) {
                        New-UDFormValidationResult -ValidationError 'First name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtLastName)) {
                        New-UDFormValidationResult -ValidationError 'Last name is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtEmail) -or
                        $EventData.txtEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
                        New-UDFormValidationResult -ValidationError 'A valid email address is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtDepartment)) {
                        New-UDFormValidationResult -ValidationError 'Department is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtJobTitle)) {
                        New-UDFormValidationResult -ValidationError 'Job title is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtManager)) {
                        New-UDFormValidationResult -ValidationError 'Manager is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.datStartDate)) {
                        New-UDFormValidationResult -ValidationError 'Start date is required.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtFirstName' -Label 'First Name'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtLastName' -Label 'Last Name'
                        }
                    }
                    New-UDTextbox -Id 'txtEmail' -Label 'Work Email' -Type 'email'
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtDepartment' -Label 'Department'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtJobTitle' -Label 'Job Title'
                        }
                    }
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtManager' -Label 'Manager'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDDatePicker -Id 'datStartDate' -Label 'Start Date'
                        }
                    }
                }
            }

            'Confirmation' {
                $formSplat['Content'] = {
                    New-UDTypography -Text 'Please confirm you wish to proceed.' -Variant 'body1'
                }
            }

            'PasswordReset' {
                $formSplat['OnValidate'] = {
                    if ([string]::IsNullOrWhiteSpace($EventData.txtUsername)) {
                        New-UDFormValidationResult -ValidationError 'Username is required.'; return
                    }
                    if ([string]::IsNullOrWhiteSpace($EventData.txtEmail) -or
                        $EventData.txtEmail -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
                        New-UDFormValidationResult -ValidationError 'A valid email address is required.'; return
                    }
                    New-UDFormValidationResult -Valid
                }
                $formSplat['Content'] = {
                    New-UDRow -Columns {
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtUsername' -Label 'Username'
                        }
                        New-UDColumn -SmallSize 6 -LargeSize 6 -Content {
                            New-UDTextbox -Id 'txtEmail' -Label 'Email Address' -Type 'email'
                        }
                    }
                    New-UDTextbox -Id 'txtReason' -Label 'Reason (optional)' -Multiline -Rows 3
                }
            }
        }

        if ($Style) {
            New-UDElement -Tag 'div' -Attributes @{ style = $Style } -Content {
                New-UDForm @formSplat
            }
        } else {
            New-UDForm @formSplat
        }
    }
}