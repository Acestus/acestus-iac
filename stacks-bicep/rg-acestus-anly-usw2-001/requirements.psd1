# PowerShell dependencies for Azure Functions
# This file is optional but helps document the PowerShell modules used

@{
    # Azure Function Host Requirements
    'powershell-yaml' = @{
        MinimumVersion = '0.4.0'
        Description    = 'YAML parsing for configuration files'
    }

    # Note: Azure Functions provides Az modules by default
    # Additional modules can be specified here if needed
}