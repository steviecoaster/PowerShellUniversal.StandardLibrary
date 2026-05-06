Get-ChildItem $PSScriptRoot\public\*.ps1 | ForEach-Object {
    . $_.FullName
}