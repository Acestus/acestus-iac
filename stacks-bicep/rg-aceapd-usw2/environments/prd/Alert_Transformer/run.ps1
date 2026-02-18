#!/usr/bin/env pwsh

param($Request, $TriggerMetadata)

# Import required modules
Import-Module Az.Accounts -Force

# Get environment variables
$teamsWebhookUrl = $env:TEAMS_WEBHOOK_URL
$functionAppName = $env:WEBSITE_SITE_NAME

Write-Host "🔄 Alert Transformer Function triggered"

# Validate webhook URL
if (-not $teamsWebhookUrl) {
    Write-Host "❌ TEAMS_WEBHOOK_URL environment variable not configured"
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = 500
            Body       = @{ error = "Teams webhook URL not configured" } | ConvertTo-Json
        })
    return
}

try {
    # Parse the Azure Monitor alert payload
    $alertData = $Request.Body

    Write-Host "📨 Received alert payload: $($alertData | ConvertTo-Json -Depth 3)"

    # Determine alert type and extract relevant information
    $alertInfo = @{
        AlertName     = "Unknown Alert"
        Severity      = "Unknown"
        Status        = "Unknown"
        Description   = "Alert received"
        ResourceName  = "Unknown"
        ResourceGroup = "Unknown"
        Timestamp     = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
    }

    # Handle different alert formats
    if ($alertData.schemaId -eq "azureMonitorCommonAlertSchema") {
        # Common Alert Schema format
        $essentials = $alertData.data.essentials
        $alertInfo.AlertName = $essentials.alertRule
        $alertInfo.Severity = "Sev$($essentials.severity)"
        $alertInfo.Status = $essentials.monitorCondition
        $alertInfo.Description = $essentials.description
        $alertInfo.ResourceName = ($essentials.alertTargetIDs | Select-Object -First 1) -replace ".*/", ""
        $alertInfo.ResourceGroup = $essentials.alertTargetIDs[0] -replace ".*/resourceGroups/([^/]+)/.*", '$1'
        $alertInfo.Timestamp = $essentials.firedDateTime
    } elseif ($alertData.context) {
        # Legacy alert format
        $context = $alertData.context
        $alertInfo.AlertName = $context.name
        $alertInfo.Description = $context.description
        $alertInfo.Status = $alertData.status
        $alertInfo.ResourceName = $context.resourceName
        $alertInfo.ResourceGroup = $context.resourceGroupName
        $alertInfo.Timestamp = $context.timestamp
    } elseif ($alertData.data.context) {
        # Activity log format
        $context = $alertData.data.context.activityLog
        $alertInfo.AlertName = $context.operationName
        $alertInfo.Status = $context.status.value
        $alertInfo.ResourceName = $context.resourceId -replace ".*/", ""
        $alertInfo.ResourceGroup = $context.resourceGroupName
        $alertInfo.Timestamp = $context.eventTimestamp
    }

    # Determine color based on alert status and severity
    $themeColor = switch -Regex ($alertInfo.Status.ToLower()) {
        "fired|activated|alert" { "FF6B6B" }      # Red
        "resolved|deactivated" { "51CF66" }       # Green
        default { "339AF0" }                       # Blue
    }

    # Create Teams MessageCard payload
    $teamsMessage = @{
        "@type"           = "MessageCard"
        "@context"        = "https://schema.org/extensions"
        "themeColor"      = $themeColor
        "summary"         = "🚨 Azure Monitor Alert: $($alertInfo.AlertName)"
        "sections"        = @(
            @{
                "activityTitle"    = "🚨 **Azure Monitor Alert**"
                "activitySubtitle" = "$($alertInfo.AlertName)"
                "facts"            = @(
                    @{
                        "name"  = "Alert Name"
                        "value" = $alertInfo.AlertName
                    },
                    @{
                        "name"  = "Severity"
                        "value" = $alertInfo.Severity
                    },
                    @{
                        "name"  = "Status"
                        "value" = $alertInfo.Status
                    },
                    @{
                        "name"  = "Resource"
                        "value" = $alertInfo.ResourceName
                    },
                    @{
                        "name"  = "Resource Group"
                        "value" = $alertInfo.ResourceGroup
                    },
                    @{
                        "name"  = "Time"
                        "value" = $alertInfo.Timestamp
                    },
                    @{
                        "name"  = "Function App"
                        "value" = $functionAppName
                    }
                )
                "markdown"         = $true
            }
        )
        "potentialAction" = @(
            @{
                "@type"   = "OpenUri"
                "name"    = "View in Azure Monitor"
                "targets" = @(
                    @{
                        "os"  = "default"
                        "uri" = "https://portal.azure.com/#view/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/~/alertsV2"
                    }
                )
            }
        )
    }

    # Convert to JSON
    $messageJson = $teamsMessage | ConvertTo-Json -Depth 10 -Compress

    Write-Host "📤 Sending message to Teams webhook"
    Write-Host "Teams message: $messageJson"

    # Send to Teams webhook
    $response = try {
        Invoke-RestMethod -Uri $teamsWebhookUrl -Method POST -Body $messageJson -ContentType 'application/json' -TimeoutSec 30
        "Success"
    } catch {
        Write-Host "❌ Failed to send to Teams: $($_.Exception.Message)"
        $_.Exception.Message
    }

    Write-Host "✅ Teams response: $response"

    # Return success response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = 200
            Body       = @{
                message       = "Alert transformed and sent to Teams successfully"
                teamsResponse = $response
            } | ConvertTo-Json
        })

} catch {
    Write-Host "❌ Error in Alert Transformer: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.ScriptStackTrace)"

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = 500
            Body       = @{
                error      = $_.Exception.Message
                stackTrace = $_.ScriptStackTrace
            } | ConvertTo-Json
        })
}