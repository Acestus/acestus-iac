
set-azcontext -subscription "Management"
New-AzTemplateSpec -Name PublicIpPolicyExemption -Version 25.06 -ResourceGroupName TemplateSpecs -Location westus2 -TemplateFile ~\git\bicep-infra\template-specs\create-policy-exemption\MainTemplate.bicep -DisplayName "Public IP Policy Exemption" -Description "Exempt a resource from the public IP policy" -Force


# Deploy a policy exemption
$RGName = "DscTest"
$params = @{
    "ChangeRequestNumber" = "CH-707"
}
$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/PublicIpPolicyExemption/versions/24.12"
set-azcontext -subscription "Acestus"
New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName $RGName -TemplateParameterObject $params





# Deploy a policy exemption for a list of Resource Groups
$RGs = @("CharisTechRG-C3", "CharisTechRG-C4", "CharisTechRG-C5")
$params = @{
    "ChangeRequestNumber" = "CH-315"
}
$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/PublicIpPolicyExemption/versions/24.12"
foreach ($RG in $RGs) {
    New-AzResourceGroup -Name $RG -Location westus2
    New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName $RG -TemplateParameterObject $params
}
