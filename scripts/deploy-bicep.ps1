[CmdletBinding()]
param(
	[Parameter(Mandatory = $true)]
	[string]$Stack,
	[Parameter()]
	[ValidateSet('dev', 'stg', 'prd')]
	[string]$Environment
)

$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\modules\Get-DeploymentVariables.psm1" -Force

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$StacksBicepRoot = Join-Path $RepoRoot "stacks-bicep"

$CandidatePath = Join-Path $StacksBicepRoot $Stack
if (-not (Test-Path $CandidatePath)) {
	Write-Host "Stack not found: $Stack (looked in $CandidatePath)" -ForegroundColor Red
	exit 1
}
$ResolvedStackPath = Resolve-Path $CandidatePath

$ResolvedPath = $ResolvedStackPath.Path
if ($ResolvedPath -like "*.bicep") {
	$StackRoot = Split-Path $ResolvedPath -Parent
} else {
	$StackRoot = $ResolvedPath
}

$TemplateFile = Join-Path $StackRoot "main.bicep"
if (-not (Test-Path $TemplateFile)) {
	Write-Host "Template file not found: $TemplateFile" -ForegroundColor Red
	exit 1
}

if ($Environment) {
	$ParamFile = Join-Path $StackRoot "environments\$Environment\main.$Environment.bicepparam"
} else {
	$ParamFile = Join-Path $StackRoot "main.bicepparam"
}

if (-not (Test-Path $ParamFile)) {
	Write-Host "Parameters file not found: $ParamFile" -ForegroundColor Red
	exit 1
}

# Check if Az.Resources module is installed
if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
	Write-Host "Az.Resources PowerShell module is not installed" -ForegroundColor Red
	Write-Host "Install it with: Install-Module -Name Az -Repository PSGallery -Force" -ForegroundColor Yellow
	exit 1
}

$DeploymentVars = Get-DeploymentVariables -ScriptRootOverride $StackRoot -ParamFileOverride $ParamFile

Write-Host ""
Write-Host "Deploying Infrastructure using Azure Deployment Stacks" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "Stack:            $Stack" -ForegroundColor White
if ($Environment) {
	Write-Host "Environment:      $Environment" -ForegroundColor White
}
Write-Host "Resource Group:   $($DeploymentVars.ResourceGroupName)" -ForegroundColor White
Write-Host "Stack Name:       $($DeploymentVars.StackParams.Name)" -ForegroundColor White
Write-Host "Template File:    $TemplateFile" -ForegroundColor White
Write-Host "Parameters File:  $ParamFile" -ForegroundColor White
Write-Host "Subscription:     $($DeploymentVars.Subscription)" -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# Set subscription context
Write-Host "Setting subscription: $($DeploymentVars.Subscription)" -ForegroundColor Cyan
Set-AzContext -Subscription $DeploymentVars.Subscription | Out-Null

# Get current subscription
$CurrentSub = (Get-AzContext).Subscription.Name
Write-Host "Using subscription: $CurrentSub" -ForegroundColor Green

# Verify resource group exists
Write-Host ""
Write-Host "Verifying resource group..." -ForegroundColor Cyan
$ResourceGroup = Get-AzResourceGroup -Name $DeploymentVars.ResourceGroupName -ErrorAction SilentlyContinue
if (-not $ResourceGroup) {
	Write-Host "Resource group '$($DeploymentVars.ResourceGroupName)' does not exist!" -ForegroundColor Red
	Write-Host "Please create the resource group first or check the name." -ForegroundColor Yellow
	exit 1
}
Write-Host "Resource group verified" -ForegroundColor Green

# Deploy the stack
Write-Host ""
Write-Host "Deploying using Azure Deployment Stacks..." -ForegroundColor Cyan

$StackParams = $DeploymentVars.StackParams
$StackParams['TemplateParameterFile'] = $ParamFile

New-AzResourceGroupDeploymentStack @StackParams

Write-Host ""
Write-Host "Deployment complete!" -ForegroundColor Green
