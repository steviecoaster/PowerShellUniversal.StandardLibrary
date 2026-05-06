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

### Guidelines

- Keep functions focused and single-purpose.
- Include comment-based help (`<# .SYNOPSIS ... #>`) for every exported function.
- Add or update tests where applicable.
- Open an issue first for significant changes to discuss the approach before submitting a PR.

## License

This project is licensed under the [MIT License](LICENSE).
