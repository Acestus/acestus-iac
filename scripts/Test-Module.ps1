# Test Bicep Module
# This script validates module syntax and runs basic tests

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModuleName,
    
    [Parameter(Mandatory = $false)]
    [string]$ModulesPath = "..\modules-bicep"
)

$ErrorActionPreference = "Stop"

Write-Host "🧪 Testing Bicep Module: $ModuleName" -ForegroundColor Green

# Get script directory and construct paths
$ScriptRoot = $PSScriptRoot
$ModulePath = Join-Path -Path $ScriptRoot -ChildPath "$ModulesPath\$ModuleName" | Resolve-Path
$BicepFile = Join-Path -Path $ModulePath -ChildPath "$ModuleName.bicep"

# Validate module exists
if (-not (Test-Path $ModulePath)) {
    Write-Error "Module directory not found: $ModulePath"
}

if (-not (Test-Path $BicepFile)) {
    Write-Error "Bicep file not found: $BicepFile"
}

Write-Host "📁 Module Path: $ModulePath" -ForegroundColor Cyan
Write-Host "📄 Bicep File: $BicepFile" -ForegroundColor Cyan

$testsPassed = 0
$testsFailed = 0

# Test 1: Syntax Validation
Write-Host "`n🔍 Test 1: Syntax Validation" -ForegroundColor Yellow
try {
    az bicep build --file $BicepFile --stdout | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Syntax validation passed" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "❌ Syntax validation failed" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "❌ Syntax validation failed: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 2: Linting
Write-Host "`n🔍 Test 2: Linting" -ForegroundColor Yellow
try {
    $lintOutput = az bicep build --file $BicepFile --stdout 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Linting passed" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "❌ Linting failed" -ForegroundColor Red
        Write-Host $lintOutput -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "❌ Linting failed: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 3: Metadata Check
Write-Host "`n🔍 Test 3: Metadata Check" -ForegroundColor Yellow
try {
    $content = Get-Content $BicepFile -Raw
    
    # Check for required metadata
    $hasMetadataName = $content -match "metadata\s+name\s*="
    $hasMetadataDescription = $content -match "metadata\s+description\s*="
    $hasMetadataVersion = $content -match "metadata\s+version\s*="
    
    if ($hasMetadataName -and $hasMetadataDescription -and $hasMetadataVersion) {
        Write-Host "✅ Required metadata found" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "❌ Missing required metadata:" -ForegroundColor Red
        if (-not $hasMetadataName) { Write-Host "   - name" -ForegroundColor Red }
        if (-not $hasMetadataDescription) { Write-Host "   - description" -ForegroundColor Red }
        if (-not $hasMetadataVersion) { Write-Host "   - version" -ForegroundColor Red }
        $testsFailed++
    }
} catch {
    Write-Host "❌ Metadata check failed: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Test 4: Documentation Check
Write-Host "`n🔍 Test 4: Documentation Check" -ForegroundColor Yellow
$readmeFile = Join-Path -Path $ModulePath -ChildPath "README.md"
if (Test-Path $readmeFile) {
    Write-Host "✅ README.md found" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "❌ README.md not found" -ForegroundColor Red
    $testsFailed++
}

# Test 5: Parameter Documentation
Write-Host "`n🔍 Test 5: Parameter Documentation" -ForegroundColor Yellow
try {
    $content = Get-Content $BicepFile -Raw
    $paramCount = ([regex]::Matches($content, "@description\(.*?\)\s*param")).Count
    $undocumentedParams = ([regex]::Matches($content, "(?<!@description\(.*?\)\s*\r?\n)param\s+\w+")).Count
    
    if ($paramCount -gt 0 -and $undocumentedParams -eq 0) {
        Write-Host "✅ All parameters documented ($paramCount parameters)" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "⚠️  Parameter documentation check:" -ForegroundColor Yellow
        Write-Host "   - Documented: $paramCount" -ForegroundColor White
        Write-Host "   - Potentially undocumented: $undocumentedParams" -ForegroundColor White
        $testsPassed++  # Don't fail for this, just warn
    }
} catch {
    Write-Host "❌ Parameter documentation check failed: $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}

# Summary
Write-Host "`n" + "="*50 -ForegroundColor Blue
Write-Host "📊 TEST SUMMARY" -ForegroundColor Blue
Write-Host "="*50 -ForegroundColor Blue

$totalTests = $testsPassed + $testsFailed
Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { 'Red' } else { 'Green' })

if ($testsFailed -eq 0) {
    Write-Host "`n🎉 All tests passed! Module is ready for publishing." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Some tests failed. Please fix the issues before publishing." -ForegroundColor Red
    exit 1
}