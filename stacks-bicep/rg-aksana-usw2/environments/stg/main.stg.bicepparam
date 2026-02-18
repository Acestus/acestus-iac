using '../../main.bicep'

param projectName = 'aksana'
param environment = 'stg'
param CAFLocation = 'usw2'
param instanceNumber = '001'

// Kubernetes configuration for staging
param kubernetesVersion = '1.30'
param systemPoolSize = 'Standard'
param agentPoolSize = ''
param skuTier = 'Free'

// Use existing shared Log Analytics workspace for monitoring
param monitoringWorkspaceResourceId = '/subscriptions/<subscription-id>/resourcegroups/Acestus-mgmt/providers/microsoft.operationalinsights/workspaces/Acestus-law'

// Principal ID for Key Vault access (deploying user/service principal)
param principalId = '00000000-0000-0000-0000-000000000000' // TODO: Set actual principal ID

param tags = {
  ManagedBy: 'https://github.com/<your-org>/<your-repo>'
  CreatedBy: '<your-username>'
  Subscription: 'Corp-710-Analytics'
  Project: 'AKS Analytics Platform'
  Environment: 'Staging'
}
