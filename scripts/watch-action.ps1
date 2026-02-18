#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Watch the latest workflow run by name
.DESCRIPTION
    This script automatically finds the most recent workflow run for a specified workflow and watches its progress
.PARAMETER WorkflowName
    The name of the workflow to watch (defaults to "Deploy Call Scripts on Config Change")
.PARAMETER Force
    Force watch even if the run is already completed
.EXAMPLE
    .\scripts\Watch-ConfigDeployment.ps1
    .\scripts\Watch-ConfigDeployment.ps1 -Force
#>

param(
    [Parameter()]
    [string]$WorkflowName = "Push to dev",
    
    [switch]$Force
)

# Add GitHub CLI to PATH if not already present
$ghPaths = @(
    "$env:ProgramFiles\GitHub CLI",
    "$env:LOCALAPPDATA\Programs\GitHub CLI",
    "${env:ProgramFiles(x86)}\GitHub CLI"
)
foreach ($ghPath in $ghPaths) {
    if (Test-Path "$ghPath\gh.exe") {
        $env:PATH = "$ghPath;$env:PATH"
        break
    }
}

try {
    Write-Host "Finding latest '$WorkflowName' workflow run..." -ForegroundColor Cyan
    
    # Get all recent runs and filter in PowerShell to avoid jq escaping issues
    $allRuns = gh run list --limit 10 --json name,databaseId,status,conclusion | ConvertFrom-Json
    $matchingRun = $allRuns | Where-Object { $_.name -eq $WorkflowName } | Select-Object -First 1
    
    if (-not $matchingRun) {
        Write-Error "No '$WorkflowName' workflow runs found"
        exit 1
    }
    
    $runId = $matchingRun.databaseId
    $runData = $matchingRun
    
    Write-Host "Found workflow run:" -ForegroundColor Green
    Write-Host "   ID: $($runData.databaseId)" -ForegroundColor Gray
    Write-Host "   Status: $($runData.status)" -ForegroundColor Gray
    Write-Host "   Conclusion: $($runData.conclusion)" -ForegroundColor Gray
    
    # Check if run is already completed and not forcing
    if ($runData.status -eq "completed" -and -not $Force) {
        if ($runData.conclusion -eq "success") {
            Write-Host "Workflow run is already completed successfully" -ForegroundColor Green
            Write-Host "Viewing run details..." -ForegroundColor Cyan
            gh run view $runId
        }
        elseif ($runData.conclusion -eq "failure") {
            Write-Host "Workflow run completed with failure" -ForegroundColor Red
            Write-Host "Viewing failed job logs..." -ForegroundColor Cyan
            gh run view $runId --log-failed
        }
        else {
            Write-Host "Workflow run completed with conclusion: $($runData.conclusion)" -ForegroundColor Yellow
            Write-Host "Viewing run details..." -ForegroundColor Cyan
            gh run view $runId
        }
        return
    }
    
    Write-Host "Watching workflow run $runId..." -ForegroundColor Cyan
    Write-Host "   Press Ctrl+C to stop watching" -ForegroundColor Gray
    
    # Watch the run with detailed logs
    $watchResult = $?
    gh run watch $runId --exit-status
    $watchResult = $?
    
    # Show appropriate logs based on result
    if ($watchResult -and $LASTEXITCODE -eq 0) {
        Write-Host "Showing run summary..." -ForegroundColor Cyan
        gh run view $runId
    }
    else {
        Write-Host "Showing failed job logs..." -ForegroundColor Red
        gh run view $runId --log-failed
    }
    
}
catch {
    Write-Error "Failed to watch deployment: $($_.Exception.Message)"
    exit 1
}