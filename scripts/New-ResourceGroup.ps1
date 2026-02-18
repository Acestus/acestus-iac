[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [Parameter()]
    [string]$Location = 'westus2',

    [Parameter()]
    [string]$Subscription
)

if ($Subscription) {
    Set-AzContext -Subscription $Subscription
}

$Tags = @{
    ManagedBy = 'https://github.com/skopos-infrastructure/iac-infra'
    CreatedBy = $env:USERNAME
}

New-AzResourceGroup -Name $Name -Location $Location -Tag $Tags -Force
