@description('The change request number associated with this policy exemption. ie. : CH-316')
param ChangeRequestNumber string
param Description string = 'Create a temporary policy exemption for Public IP for the seleted RG'
@allowed([
  '3'
  '7'
  '14'
  '30'
])
param DaysUntilExpiration string = '7'
param currentTime string = utcNow()

var DisplayName01 = 'Policy exemption to associate Public IPs per ${ChangeRequestNumber}'
var DisplayName02 = 'Policy exemption to create Public IPs per ${ChangeRequestNumber}'
var policyAssignmentId01 = '/providers/microsoft.management/managementgroups/Acestus/providers/microsoft.authorization/policyassignments/a11d1d6cd8ec4a7ea4dd734e'
var policyAssignmentId02 = '/providers/microsoft.management/managementgroups/Acestus/providers/microsoft.authorization/policyassignments/a11d1d6cd8ec4a7ea4dd734e'
var expiresOn = dateTimeAdd(currentTime, 'P${DaysUntilExpiration}D')

resource NICPolicy 'Microsoft.Authorization/policyExemptions@2022-07-01-preview' = {
  scope: resourceGroup()
  name: DisplayName01
  properties: {
    assignmentScopeValidation: 'Default'
    description: Description
    displayName: DisplayName01
    exemptionCategory: 'Waiver'
    expiresOn: expiresOn
    metadata: {
      category: 'string'
    }
    policyAssignmentId: policyAssignmentId01
  }
}

resource CreateIP 'Microsoft.Authorization/policyExemptions@2022-07-01-preview' = {
  scope: resourceGroup()
  name: DisplayName02
  properties: {
    assignmentScopeValidation: 'Default'
    description: Description
    displayName: DisplayName02
    exemptionCategory: 'Waiver'
    expiresOn: expiresOn
    metadata: {
      category: 'string'
    }
    policyAssignmentId: policyAssignmentId02
  }
}

output resourceGroupName string = resourceGroup().name
output expiresOn string = expiresOn
output policyAssignmentId01 string = policyAssignmentId01
output policyAssignmentId02 string = policyAssignmentId02

