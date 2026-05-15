# PowerShellUniversal.StandardLibrary

A Standard Library of tools, utilities, and helper functions designed to streamline app development within the [PowerShell Universal](https://ironmansoftware.com/powershell-universal) platform.

## Overview

`PowerShellUniversal.StandardLibrary` provides a curated set of reusable PowerShell functions and components that simplify common tasks encountered when building dashboards, APIs, automations, and portals in PowerShell Universal. Instead of reinventing the wheel for every project, import this library and get started with a solid foundation of pre-built tools.

## Installation

### From Within PowerShell Universal

1. Open your **PowerShell Universal** admin portal.
2. Navigate to **Platform** → **Modules**.
3. Search for `PowerShellUniversal.StandardLibrary` in the module repository.
4. Click **Install** and wait for the installation to complete.

Alternatively, you can install the module via the PowerShell Universal integrated terminal or a Script:

```powershell
Install-Module -Name PowerShellUniversal.StandardLibrary -Repository PSGallery -Force
```

### Importing the Module

Once installed, import the module in your scripts, dashboards, or API endpoints:

```powershell
Import-Module PowerShellUniversal.StandardLibrary
```

To make the module available globally across your PowerShell Universal instance, add it to your `environments` configuration or include it in your `scripts/settings.ps1` file.

## Usage

After importing the module, all exported functions will be available in your PowerShell Universal scripts and components. Refer to the individual function documentation (via `Get-Help <FunctionName>`) for details on available commands.

```powershell
# Example
Get-Command -Module PowerShellUniversal.StandardLibrary
```

## Examples

The [`EXAMPLES/`](EXAMPLES/) folder contains ready-to-run scripts that demonstrate each component. Copy the contents of an example into a PowerShell Universal **App** or **Dashboard** page to see it in action.

| File | Description |
|------|-------------|
| [ActionGroup.ps1](EXAMPLES/ActionGroup.ps1) | Demonstrates `New-UDActionGroup` with four styling variations (standard, outlined, text/ghost, and custom) and a live direction selector. |
| [DynamicDataCard.ps1](EXAMPLES/DynamicDataCard.ps1) | Shows `New-UDDataCard` rendering live metric cards with auto-refresh and manual refresh patterns. |
| [DynamicTable.ps1](EXAMPLES/DynamicTable.ps1) | Shows `New-UDDynamicTable` with server-side data loading and row actions. |
| [JobModal.ps1](EXAMPLES/JobModal.ps1) | Demonstrates `Show-UDJobOutputModal` for surfacing job output inside a modal dialog. |
| [Demo.ps1](EXAMPLES/Demo.ps1) | A combined kitchen-sink demo of all components on a single page. |

## Contributing

Contributions are welcome! If you have a utility or helper function that would benefit the PowerShell Universal community, feel free to get involved.

1. **Fork** this repository.
2. **Create a branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/my-new-tool
   ```
3. **Commit** your changes with a clear and descriptive message:
   ```bash
   git commit -m "Add: utility function for X"
   ```
4. **Push** your branch and open a **Pull Request** against `main`.
5. Ensure your code follows existing conventions and includes appropriate documentation (`Get-Help` compatible comment blocks).

### Running the Test Harness

Before submitting a PR, run the included [Pester](https://pester.dev) test suite to validate code quality across all public functions. Pester 5.0 or later is required.

```powershell
# Install Pester if not already present
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force

# Run all tests from the repository root
.\Invoke-Tests.ps1
```

Results are printed to the console and also written to `TestResults.xml` in NUnit format, which is compatible with CI systems such as GitHub Actions.

The test harness enforces:
- Comment-based help completeness (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`) on every exported function
- Naming convention compliance (`<Verb>-<Prefix><Noun>`)
- Structural requirements (no bare code outside functions in public files)
- Common PowerShell code smell checks

### Guidelines

- Keep functions focused and single-purpose.
- Include comment-based help (`<# .SYNOPSIS ... #>`) for every exported function.
- Add or update tests where applicable.
- Open an issue first for significant changes to discuss the approach before submitting a PR.

## License

This project is licensed under the [MIT License](LICENSE).
