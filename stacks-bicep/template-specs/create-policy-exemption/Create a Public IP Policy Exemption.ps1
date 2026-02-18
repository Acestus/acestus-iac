# Create a Public IP Policy Exemption
$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/PublicIpPolicyExemption/versions/24.12"
$subscription = "Sbox-510-Infrastructure"
$resourceGroup = "DscTest"
$params = @{
    ChangeRequestNumber = "CH-000"
    DaysUntilExpiration = "30"
}
set-azcontext -subscription $subscription
# New-AzResourceGroup -name $resourceGroup -location "westus2"
New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName $resourceGroup -TemplateParameterObject $params
