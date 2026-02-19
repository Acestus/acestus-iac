# Deploy a template spec to create a Linux VM

cd ~\git\bicep-infra\template-specs\create-linux-vm
set-azcontext -subscription "Management"
New-AzTemplateSpec -Name "DeployLinuxVM" -Version 24.12 -ResourceGroupName TemplateSpecs -Location westus2 -TemplateFile ./mainTemplate-vanilla.bicep -DisplayName "Deploy Linux VM" -Description "Deploy a Linux VM" -Force

# Deploy a template spec to create a Net Tools VM

set-azcontext -subscription "Management"
New-AzTemplateSpec -Name "DeployNetToolsVM" -Version 25.06 -ResourceGroupName TemplateSpecs -Location westus2 -TemplateFile ~\git\bicep-infra\template-specs\create-linux-vm\mainTemplate-NetToolsVM.bicep -DisplayName "Deploy Net Tools VM" -Description "Deploy a Linux VM with network tools" -Force

# Deploy Linux VM
$RGName = "DscTest"
$params = @{
    "adminUsername" = "adminuser"
    "instanceNumber" = "002"
}
$TemplateSpecId = "/subscriptions/<subscription-id>/resourceGroups/TemplateSpecs/providers/Microsoft.Resources/templateSpecs/DeployNetToolsVM/versions/24.12"
set-azcontext -subscription "Acestus"
New-AzResourceGroupDeployment -TemplateSpecId $TemplateSpecId -ResourceGroupName $RGName -TemplateParameterObject $params
