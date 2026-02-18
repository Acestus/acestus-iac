function Get-DeploymentVariables {
    param(
        [Parameter()]
        [string]$ScriptRootOverride,
        [Parameter()]
        [string]$ParamFileOverride
    )

    # Get the calling script's directory unless overridden
    if ($ScriptRootOverride) {
        $ScriptRoot = (Resolve-Path $ScriptRootOverride).Path
    } else {
        $ScriptRoot = (Get-PSCallStack)[1].ScriptName | Split-Path
    }
    
    # Extract values from bicepparam file
    if ($ParamFileOverride) {
        $ParamFile = (Resolve-Path $ParamFileOverride).Path
    } else {
        $ParamFile = Join-Path $ScriptRoot "main.bicepparam"
    }

    if (-not (Test-Path $ParamFile)) {
        Write-Error "Parameter file not found: $ParamFile"
        return
    }
    $ParamContent = Get-Content $ParamFile -Raw

    # Build a lookup of simple param values (single-quoted strings)
    $ParamValues = @{}
    foreach ($match in [regex]::Matches($ParamContent, "param\s+([A-Za-z0-9_]+)\s*=\s*'([^']*)'")) {
        $ParamValues[$match.Groups[1].Value] = $match.Groups[2].Value
    }

    # Extract CAFName - try legacy param first, then build from separated params
    if ($ParamValues.ContainsKey('CAFName')) {
        $CAFName = $ParamValues['CAFName']
    } elseif ($ParamValues.ContainsKey('projectName') -and $ParamValues.ContainsKey('environment') -and 
              $ParamValues.ContainsKey('CAFLocation') -and $ParamValues.ContainsKey('instanceNumber')) {
        # Build CAFName from separated params
        $CAFName = "$($ParamValues['projectName'])-$($ParamValues['environment'])-$($ParamValues['CAFLocation'])-$($ParamValues['instanceNumber'])"
    } elseif ($ParamContent -match "CAFName:\s*'([^']+)'") {
        $CAFNameTemplate = $matches[1]
        try {
            $CAFName = [regex]::Replace($CAFNameTemplate, '\$\{([^}]+)\}', {
                param($m)
                $key = $m.Groups[1].Value
                if ($ParamValues.ContainsKey($key)) {
                    return $ParamValues[$key]
                }
                throw "CAFName token '$key' not found in $ParamFile"
            })
        } catch {
            Write-Error $_.Exception.Message
            return
        }
    } else {
        Write-Error "CAFName not found - need either CAFName param or separated params (projectName, environment, CAFLocation, instanceNumber) in $ParamFile"
        return
    }
    $ResourceGroupName = "rg-$CAFName"
    $StackName = "stack-$CAFName"

    # Extract subscription
    if ($ParamContent -match "Subscription:\s*'([^']+)'") {
        $Subscription = $matches[1]
    } else {
        Write-Error "Subscription not found in tags section of $ParamFile"
        return
    }
    
    return @{
        StackParams = @{
            Name                    = $StackName
            ResourceGroupName       = $ResourceGroupName
            TemplateFile           = "$ScriptRoot\main.bicep"
            DenySettingsMode       = "None"
            ActionOnUnmanage       = "DeleteResources"
        }
        Subscription = $Subscription
        ResourceGroupName = $ResourceGroupName
        StackName = $StackName
    }
}

Export-ModuleMember -Function Get-DeploymentVariables