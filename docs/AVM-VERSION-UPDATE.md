# AVM Module Version Update Process

This document describes how to update Azure Verified Module (AVM) versions across Bicep and Terraform modules in this repository.

## Overview

Azure Verified Modules (AVM) are Microsoft's official, well-architected infrastructure modules. Keeping them updated ensures you have:
- Latest security fixes
- Bug fixes and improvements
- New features and capabilities

## Prerequisites

- PowerShell 7+ (pwsh)
- Access to the AVM module index HTML files (for extracting latest versions)

## Source Files

| File | Purpose |
|------|---------|
| `modules-bicep/avm-modules.html` | Bicep AVM module index (from [AVM website](https://azure.github.io/Azure-Verified-Modules/indexes/bicep/bicep-resource-modules/)) |
| `modules-bicep/terraform-avm.html` | Terraform AVM module index (from [AVM website](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/)) |
| `modules-bicep/avm-versions.csv` | Extracted Bicep module versions |
| `modules-terraform/terraform-avm-versions.csv` | Extracted Terraform module versions |

---

## Bicep Modules

### Update Process

1. **Download Latest AVM Index**
   
   Visit [Bicep Resource Modules](https://azure.github.io/Azure-Verified-Modules/indexes/bicep/bicep-resource-modules/) and save the page as HTML to `modules-bicep/avm-modules.html`.

2. **Extract Versions to CSV** (optional - script reads HTML directly or CSV)
   
   The CSV provides a smaller, faster reference file:
   ```powershell
   # Extract from HTML to CSV
   $html = Get-Content ".\modules-bicep\avm-modules.html" -Raw
   $output = @("Module,Version")
   $matches = [regex]::Matches($html, 'tree/main/(avm/res/[a-z0-9-]+/[a-z0-9-]+)>.*?badge/[^-]+-(\d+\.\d+\.\d+)-blue')
   foreach ($m in $matches) {
       $output += "$($m.Groups[1].Value),$($m.Groups[2].Value)"
   }
   $output | Select-Object -Unique | Out-File ".\modules-bicep\avm-versions.csv" -Encoding utf8
   ```

3. **Preview Changes**
   ```powershell
   .\scripts\Update-AvmVersions.ps1 -Preview
   ```

4. **Apply Updates**
   ```powershell
   .\scripts\Update-AvmVersions.ps1
   ```

### Bicep Module Reference Format

Bicep references AVM modules using:
```bicep
module storageAccount 'br/public:avm/res/storage/storage-account:0.31.0' = {
  // ...
}
```

The script updates the version number at the end of the module path.

### Files Affected

- `modules-bicep/**/*.bicep`
- `stacks-bicep/**/*.bicep`

---

## Terraform Modules

### Update Process

1. **Download Latest AVM Index**
   
   Visit [Terraform Resource Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/) and save the page as HTML to `modules-bicep/terraform-avm.html`.

2. **Extract Versions to CSV**
   ```powershell
   $html = Get-Content ".\modules-bicep\terraform-avm.html" -Raw
   $output = @("Module,Version")
   $matches = [regex]::Matches($html, 'registry\.terraform\.io/modules/Azure/(avm-res-[a-z0-9-]+)/azurerm/latest.*?badge/[A-Za-z%0-9]+-(\d+\.\d+\.\d+)-purple')
   foreach ($m in $matches) {
       $output += "$($m.Groups[1].Value),$($m.Groups[2].Value)"
   }
   $output | Select-Object -Unique | Out-File ".\modules-terraform\terraform-avm-versions.csv" -Encoding utf8
   ```

3. **Preview Changes**
   ```powershell
   .\scripts\Update-TerraformAvmVersions.ps1 -Preview
   ```

4. **Apply Updates** (uses pessimistic constraint `~> X.Y` by default)
   ```powershell
   .\scripts\Update-TerraformAvmVersions.ps1
   ```

5. **Apply Updates with Exact Versions** (optional)
   ```powershell
   .\scripts\Update-TerraformAvmVersions.ps1 -UseExactVersion
   ```

### Terraform Module Reference Format

Terraform references AVM modules using:
```hcl
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6"  # or "0.6.7" for exact version
  // ...
}
```

### Version Constraint Strategies

| Strategy | Example | Description |
|----------|---------|-------------|
| Pessimistic (default) | `~> 0.6` | Allows 0.6.x but not 0.7.0+ |
| Exact | `0.6.7` | Pins to specific version |

### Files Affected

- `modules-terraform/**/*.tf`
- `stacks-terraform/**/*.tf`

---

## Script Reference

### Update-AvmVersions.ps1 (Bicep)

```powershell
# Parameters
-CsvPath     # Path to CSV (default: modules-bicep/avm-versions.csv)
-SearchPath  # Root path to search (default: repository root)
-Preview     # Show changes without applying
```

### Update-TerraformAvmVersions.ps1 (Terraform)

```powershell
# Parameters
-CsvPath         # Path to CSV (default: modules-terraform/terraform-avm-versions.csv)
-SearchPath      # Root path to search (default: repository root)
-Preview         # Show changes without applying
-UseExactVersion # Use exact versions instead of pessimistic constraint
```

---

## Maintenance Schedule

Recommend updating AVM versions:
- **Monthly**: For non-critical environments
- **Quarterly**: For production environments
- **Immediately**: When security advisories are published

## Troubleshooting

### Script reports 0 modules found

1. Ensure the HTML file exists and is not corrupted
2. Check that the HTML structure hasn't changed significantly
3. Verify the CSV file has valid `Module,Version` format

### Version appears to downgrade

The HTML index may occasionally show older versions for certain modules. Review the changes before applying:
```powershell
# Always preview first
.\scripts\Update-AvmVersions.ps1 -Preview
```

### Terraform init fails after update

Run `terraform init -upgrade` to update the provider lock file:
```powershell
terraform init -upgrade
```

---

## Additional Resources

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Bicep Modules](https://azure.github.io/Azure-Verified-Modules/indexes/bicep/)
- [AVM Terraform Modules](https://azure.github.io/Azure-Verified-Modules/indexes/terraform/)
- [Terraform Version Constraints](https://developer.hashicorp.com/terraform/language/expressions/version-constraints)
