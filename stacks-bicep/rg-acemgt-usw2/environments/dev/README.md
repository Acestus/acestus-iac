# Alert Transformer Function Deployment - Development Environment

This directory contains the infrastructure and function code for deploying an Azure Function that transforms Azure Monitor alerts and sends them to Microsoft Teams.

## Overview

The Alert Transformer function receives Azure Monitor alert webhooks, parses different alert formats, and sends formatted messages to a Microsoft Teams channel. It supports multiple alert schema types including:

- **Common Alert Schema** (recommended)
- **Legacy Alert Schema** (classic alerts)
- **Activity Log Alerts**

## Architecture

```
Azure Monitor Alert → Action Group → Function App → Teams Webhook
                                   ↓
                              Application Insights
```

### Resources Created

- **Function App** (PowerShell 7.4 runtime)
- **App Service Plan** (Consumption Y1 SKU)
- **Storage Account** (for function runtime)
- **Application Insights** (for monitoring and logging)
- **Email Action Group** (for email notifications)
- **Teams Action Group** (for Teams notifications via function)

## Files Structure

```
rg-acestus-mgmt-usw2-002/
├── Alert_Transformer/
│   ├── function.json          # Function binding configuration
│   └── run.ps1                # Function PowerShell code
├── main.bicep                 # Infrastructure as Code template
├── main.bicepparam           # Deployment parameters
├── host.json                 # Function app host configuration
├── requirements.psd1         # PowerShell module dependencies
├── deploy-alert-transformer.ps1  # Deployment script
├── test-alert-transformer.ps1    # Testing script
└── README.md                 # This documentation
```

## Prerequisites

1. **Azure PowerShell Module**: Install with `Install-Module -Name Az -Force`
2. **Azure Authentication**: Login with `Connect-AzAccount`
3. **Teams Webhook URL**: Create an incoming webhook connector in your Teams channel

### Getting Teams Webhook URL

1. Go to your Teams channel
2. Click on "..." (More options) → "Connectors"
3. Search for "Incoming Webhook" and click "Add"
4. Click "Add" again and configure the webhook:
   - Name: "Azure Monitor Alerts"
   - Upload an icon (optional)
   - Click "Create"
5. Copy the webhook URL provided

## Deployment

### Step 1: Update Parameters

Edit `main.bicepparam` and replace `<TEAMS_WEBHOOK_URL_PLACEHOLDER>` with your actual Teams webhook URL:

```bicep
param teamsWebhookUrl = 'https://your-org.webhook.office.com/webhookb2/...'
```

### Step 2: Deploy Infrastructure and Function

Run the deployment script:

```powershell
.\deploy-alert-transformer.ps1 -TeamsWebhookUrl "https://your-teams-webhook-url"
```

### Step 3: Test the Function

After deployment, test the function:

```powershell
.\test-alert-transformer.ps1 -FunctionUrl "https://your-function-app.azurewebsites.net/api/Alert_Transformer"
```

## Configuration

### Environment Variables

The function uses the following environment variables:

- `TEAMS_WEBHOOK_URL`: Microsoft Teams incoming webhook URL (set via Bicep parameter)
- `WEBSITE_SITE_NAME`: Function app name (automatically set by Azure)
- `APPINSIGHTS_INSTRUMENTATIONKEY`: Application Insights key (automatically set)
- `APPLICATIONINSIGHTS_CONNECTION_STRING`: Application Insights connection string (automatically set)

### Function Settings

The function is configured with:

- **Runtime**: PowerShell 7.4
- **Function Version**: ~4
- **Timeout**: 10 minutes
- **Authentication Level**: Anonymous (for webhook calls)

## Usage

### Setting Up Azure Monitor Alerts

1. **Create an Alert Rule** in Azure Monitor
2. **Configure Action Group**: Use the deployed Teams Action Group
3. **Test the Alert**: Trigger the alert condition or use the test feature

### Alert Processing

The function processes different alert formats:

#### Common Alert Schema
```json
{
  "schemaId": "azureMonitorCommonAlertSchema",
  "data": {
    "essentials": {
      "alertRule": "CPU Usage High",
      "severity": "Sev2",
      "monitorCondition": "Fired",
      // ... more fields
    }
  }
}
```

#### Legacy Schema
```json
{
  "status": "Activated",
  "context": {
    "name": "Alert Name",
    "description": "Alert Description",
    // ... more fields
  }
}
```

### Teams Message Format

The function sends formatted Microsoft Teams cards with:

- **Alert Name**: The name of the triggered alert
- **Severity**: Alert severity level (Sev0-Sev4)
- **Status**: Current status (Fired, Resolved, etc.)
- **Resource**: Affected Azure resource name
- **Resource Group**: Resource group name
- **Timestamp**: When the alert was fired
- **Action Button**: Link to Azure Monitor

## Monitoring and Troubleshooting

### Application Insights

Monitor function execution, performance, and errors in Application Insights:

1. Go to Azure Portal → Your Function App → Application Insights
2. Check "Live Metrics" for real-time monitoring
3. Review "Failures" for error details
4. Use "Logs" (KQL) for detailed analysis

### Function Logs

View function execution logs:

1. Azure Portal → Function App → Functions → Alert_Transformer → Monitor
2. Or stream logs: Azure Portal → Function App → Log stream

### Common Issues

1. **Teams webhook not working**:
   - Verify webhook URL is correct
   - Check if webhook was disabled in Teams
   - Ensure TEAMS_WEBHOOK_URL environment variable is set

2. **Function not triggered**:
   - Verify Action Group configuration
   - Check function app is running
   - Review alert rule configuration

3. **Function errors**:
   - Check Application Insights for detailed error messages
   - Review function logs in Azure Portal
   - Verify PowerShell module dependencies

## Security Considerations

- **Webhook URL**: Stored as a secure parameter in Bicep template
- **HTTPS Only**: Function app configured for HTTPS traffic only
- **TLS 1.2**: Minimum TLS version enforced
- **FTPS Only**: FTP access restricted to FTPS only
- **Managed Identity**: Consider using managed identity for enhanced security

## Customization

### Modifying Alert Format

To customize the Teams message format, edit `Alert_Transformer/run.ps1`:

1. Modify the `$teamsMessage` object structure
2. Add custom fields to the "facts" array
3. Update color scheme in the `$themeColor` switch statement

### Adding More Alert Types

To support additional alert schemas:

1. Add new condition blocks in the alert parsing section
2. Extract relevant fields into the `$alertInfo` object
3. Test with the new alert format

### Extending Functionality

Consider these enhancements:

- Add alert filtering based on severity
- Implement alert throttling/deduplication
- Add integration with other notification systems
- Store alert history in a database

## Cost Estimation

Estimated monthly costs (based on moderate usage):

- **Function App** (Consumption): ~$0.50/month (1M executions)
- **Storage Account**: ~$1.00/month
- **Application Insights**: ~$2.00/month (basic telemetry)
- **Total**: ~$3.50/month

## Support and Maintenance

### Updates

To update the function:

1. Modify the function code in `Alert_Transformer/run.ps1`
2. Run the deployment script again
3. Test the updated function

### Backup

Important files to backup:

- `main.bicep` and `main.bicepparam`: Infrastructure configuration
- `Alert_Transformer/run.ps1`: Function logic
- Teams webhook URL: Store securely

## References

- [Azure Functions PowerShell Developer Guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-powershell)
- [Azure Monitor Common Alert Schema](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/alerts-common-schema)
- [Teams Incoming Webhooks](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)