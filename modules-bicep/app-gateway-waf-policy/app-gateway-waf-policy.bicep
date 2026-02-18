// Opinionated WAF policy module following Acestus standards

metadata name = 'Acestus Application Gateway WAF Policy'
metadata description = 'WAF Policy module with Acestus security defaults'
metadata version = '1.0.0'

@description('Name of the WAF policy')
param name string

@description('Location for the WAF policy')
param location string = resourceGroup().location

@description('Tags to apply to the resource')
param tags object = {}

@description('WAF mode')
@allowed([
  'Detection'
  'Prevention'
])
param mode string = 'Prevention'

@description('WAF state')
@allowed([
  'Enabled'
  'Disabled'
])
param state string = 'Enabled'

@description('Enable request body check')
param requestBodyCheck bool = true

@description('Request body size limit in KB')
@minValue(8)
@maxValue(128)
param requestBodySizeLimitInKb int = 128

@description('File upload limit in MB')
@minValue(1)
@maxValue(750)
param fileUploadLimitInMb int = 100

@description('Max request body size in KB for inspection')
@minValue(8)
@maxValue(128)
param maxRequestBodySizeInKb int = 128

@description('Rule set type')
@allowed([
  'OWASP'
  'Microsoft_DefaultRuleSet'
  'Microsoft_BotManagerRuleSet'
])
param ruleSetType string = 'OWASP'

@description('Rule set version')
param ruleSetVersion string = '3.2'

@description('Managed rule sets configuration')
param managedRuleSets array = []

@description('Custom rules configuration')
param customRules array = []

@description('Exclusions configuration')
param exclusions array = []

// Build default managed rule sets if not provided
var defaultManagedRuleSets = empty(managedRuleSets) ? [
  {
    ruleSetType: ruleSetType
    ruleSetVersion: ruleSetVersion
  }
] : managedRuleSets

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    policySettings: {
      mode: mode
      state: state
      requestBodyCheck: requestBodyCheck
      requestBodySizeLimitInKb: requestBodySizeLimitInKb
      fileUploadLimitInMb: fileUploadLimitInMb
      maxRequestBodySizeInKb: maxRequestBodySizeInKb
    }
    managedRules: {
      managedRuleSets: defaultManagedRuleSets
      exclusions: exclusions
    }
    customRules: customRules
  }
}

@description('The resource ID of the WAF policy')
output resourceId string = wafPolicy.id

@description('The name of the WAF policy')
output name string = wafPolicy.name
