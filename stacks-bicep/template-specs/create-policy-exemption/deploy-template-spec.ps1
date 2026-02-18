pwsh
set-azcontext -subscription "Management"
$Name = "PublicIpPolicyExemption"
cd ~/git/iac/create-policy-exemption
New-AzTemplateSpec -Name $Name -Version 24.12 -ResourceGroupName TemplateSpecs -Location westus2 -TemplateFile ./mainTemplate.bicep -Force


$Name = "PublicIpPolicyExemption"
$id = Get-AzTemplateSpec -ResourceGroupName TemplateSpecs -Name $Name | Select-Object -ExpandProperty Id
$id
$version = Get-AzTemplateSpec -ResourceGroupName TemplateSpecs -Name $Name | Select-Object -ExpandProperty Versions | Select-Object -ExpandProperty Name
$version
$TemplateSpecId = $id + "/versions/" + $version
$TemplateSpecId

$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/PublicIpPolicyExemption/versions/24.12"

New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName DscTest


# Create a Public IP Policy Exemption
$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/PublicIpPolicyExemption/versions/24.12"
$subscription = "Sbox-510-Infrastructure"
$resourceGroup = "DscTest"
$params = @{
    ChangeRequestNumber = "CH-000"
    DaysUntilExpiration = "30"
}
set-azcontext -subscription $subscription
New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName $resourceGroup -TemplateParameterObject $params
