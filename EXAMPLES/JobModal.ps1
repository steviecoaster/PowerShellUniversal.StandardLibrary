#region Monitor script
<#
    PREREQUISITES — set up the Monitor.ps1 script in PowerShell Universal before running this app.

    1. In the PSU web interface go to: Automation -> Scripts -> Create Script
    2. Name the script exactly: Monitor.ps1
    3. Paste the script body below (lines prefixed with ##) as the script content and save it.

    The script simulates a long-running background job by printing timestamped status phrases and
    pausing for a random delay between iterations. It is intentionally simple so you can focus on
    how Show-UDJobOutputModal streams its output, rather than on what the job itself does.
#>

## $phrases = @(
##     "Monitor heartbeat",
##     "Checking status",
##     "Processing event",
##     "Worker active",
##     "Test notification",
##     "Polling endpoint",
##     "Task completed",
##     "Signal received"
## )
##
## 1..10 | ForEach-Object {
##     $phrase = Get-Random -InputObject $phrases
##     $timestamp = Get-Date -Format "HH:mm:ss"
##
##     Write-Host "[$timestamp] $phrase"
##
##     # Sleep for a random time between 0 and 3 seconds
##     Start-Sleep -Milliseconds (Get-Random -Minimum 0 -Maximum 3000)
## }
#endregion

#region Sample App
<#
    HOW THIS EXAMPLE WORKS

    Clicking the "Show Output" button calls Show-UDJobOutputModal, which:
      1. Looks up the named PSU script (Monitor.ps1).
      2. Starts a new job for that script via the PSU API.
      3. Opens a modal dialog inside the running dashboard.
      4. Polls the job every two seconds and streams its Write-Host output into a terminal-style
         pane inside the modal in real time.
      5. Appends a final status line and automatically closes the modal once the job finishes.

    NOTE — -TrustCertificate
    This switch is required when your PSU server uses a self-signed or otherwise untrusted TLS
    certificate (the default for local development installs). Remove the switch when connecting to
    a PSU instance that has a trusted certificate, such as a production server with a CA-signed cert.
#>
New-UDApp -Title 'Simple job monitor' -Content {
    New-UDButton -Text "Show Output" -OnClick { 
        Show-UDJobOutputModal -Script Monitor.ps1 -TrustCertificate
    }
}
#endregion